import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import {
  Key,
  matchesKey,
  truncateToWidth,
  SelectList,
  type SelectListTheme,
  type Theme,
} from "@mariozechner/pi-tui";
import { resolve, isAbsolute, relative } from "node:path";
import { stat, readFile } from "node:fs/promises";

// --- Configuration & State ---

const SAFE_COMMANDS = new Set([
  "ls", "pwd", "git status", "git diff", "git log", "head", "tail",
  "grep", "echo", "which", "type", "find", "du", "df", "ps aux"
]);

// Shell operators that could chain unsafe commands after a safe one
const SHELL_OPERATORS = /[;&|`$(){}]/;

const SENSITIVE_PATTERNS = [
  /\.env(\.|$)/, /\.ssh/, /\/etc\//, /\.aws/, /secret/i,
  /api[_-]?key/i, /\.pem$/, /\.key$/, /token/i, /password/i, /credential/i,
];

// Session-based permissions
const sessionAllowed = new Set<string>();

function getSessionKey(toolName: string, input: any): string {
  if (toolName === "bash") {
    return `bash:${input.command}`;
  }
  if (toolName === "read" || toolName === "write" || toolName === "edit") {
    return `${toolName}:${input.path}`;
  }
  return `${toolName}:${JSON.stringify(input)}`;
}

// --- UI Components ---

class PermissionPrompt {
  private list: SelectList;

  constructor(
    private toolName: string,
    private details: string[],
    private theme: Theme,
    private onDone: (result: "once" | "session" | "deny") => void
  ) {
    const listTheme: SelectListTheme = {
      selectedPrefix: (t) => theme.fg("accent", t),
      selectedText: (t) => theme.bg("selectedBg", t),
      description: (t) => theme.fg("text", t),
      scrollInfo: (t) => theme.fg("text", t),
      noMatch: (t) => theme.fg("text", t),
    };

    this.list = new SelectList(
      [
        { value: "once", label: "Allow once" },
        { value: "session", label: "Allow for this session" },
        { value: "deny", label: "Deny" },
      ],
      3,
      listTheme
    );
    this.list.onSelect = (item) => onDone(item.value as "once" | "session" | "deny");
    this.list.onCancel = () => onDone("deny");
  }

  handleInput(data: string) {
    if (matchesKey(data, "1")) { this.onDone("once"); return; }
    if (matchesKey(data, "2")) { this.onDone("session"); return; }
    if (matchesKey(data, "3") || matchesKey(data, Key.escape)) { this.onDone("deny"); return; }
    this.list.handleInput?.(data);
  }

  render(width: number): string[] {
    const lines: string[] = [];
    lines.push(truncateToWidth(this.theme.fg("accent", `Permission Request: ${this.toolName}`), width));
    lines.push("");
    for (const d of this.details) {
      lines.push(truncateToWidth(this.theme.fg("text", d), width));
    }
    lines.push("");
    lines.push(truncateToWidth(this.theme.fg("text", "  [1] once  [2] session  [3] deny"), width));
    lines.push("");
    lines.push(...this.list.render(width));
    return lines;
  }

  invalidate() {
    this.list.invalidate?.();
  }
}

// --- Helper Functions ---

async function getReadDetails(path: string, cwd: string): Promise<string[]> {
  const absPath = isAbsolute(path) ? path : resolve(cwd, path);
  try {
    const s = await stat(absPath);
    const details = [`Path: ${path}`, `Size: ${s.size} bytes`];

    if (s.isFile()) {
      const content = await readFile(absPath, "utf8");
      const previewLines = content.split("\n").slice(0, 3);
      details.push("Preview:");
      previewLines.forEach(l => details.push(`  ${l.slice(0, 50)}`));
    }
    return details;
  } catch (e) {
    return [`Path: ${path}`, "Error: File not found or inaccessible"];
  }
}

function isSensitive(path: string, cwd: string): boolean {
  let absPath = isAbsolute(path) ? path : resolve(cwd, path);

  if (path.startsWith("~/")) {
    const home = process.env.HOME || "/home/pablito";
    absPath = resolve(home, path.slice(2));
  }

  if (SENSITIVE_PATTERNS.some(p => p.test(absPath))) return true;

  const rel = relative(cwd, absPath);
  if (rel.startsWith("..")) return true;

  return false;
}

function isSafeBash(command: string): boolean {
  // Reject anything with shell operators that could chain unsafe commands
  if (SHELL_OPERATORS.test(command)) return false;
  const baseCmd = command.trim().split(/\s+/)[0];
  return SAFE_COMMANDS.has(baseCmd);
}

// --- Extension Entry Point ---

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const { toolName, input } = event;
    const sessionKey = getSessionKey(toolName, input);

    // 1. Check Session Permissions
    if (sessionAllowed.has(sessionKey)) {
      return;
    }

    // 2. Check Tool Specific Auto-Approvals
    if (isToolCallEventType("bash", event)) {
      if (isSafeBash(event.input.command)) return;
    }

    if (isToolCallEventType("read", event)) {
      if (!isSensitive(event.input.path, ctx.cwd)) return;
    }

    // 3. Prepare Prompt Details
    let details: string[] = [];
    if (isToolCallEventType("bash", event)) {
      details = [`Command: ${event.input.command}`];
    } else if (isToolCallEventType("read", event)) {
      details = await getReadDetails(event.input.path, ctx.cwd);
    } else if (isToolCallEventType("write", event)) {
      details = [`Action: Write`, `Path: ${event.input.path}`, `Content size: ${event.input.content.length} characters`, "Preview:"];
      event.input.content.split("\n").slice(0, 3).forEach(l => details.push(`  ${l.slice(0, 60)}`));
    } else if (isToolCallEventType("edit", event)) {
      details = [`Action: Edit`, `Path: ${event.input.path}`, `Changes: ${event.input.edits.length} blocks`];
      if (event.input.edits.length > 0) {
        details.push("First Edit Block:");
        const first = event.input.edits[0];
        details.push("  - Old: " + first.oldText.split("\n")[0].slice(0, 50) + "...");
        details.push("  - New: " + first.newText.split("\n")[0].slice(0, 50) + "...");
      }
    } else {
      details = [JSON.stringify(input, null, 2)];
    }

    // 4. Show Prompt
    const result = await ctx.ui.custom<"once" | "session" | "deny" | null>((tui, theme, kb, done) => {
      const prompt = new PermissionPrompt(toolName, details, theme, done);
      return {
        render: (w) => prompt.render(w),
        handleInput: (d) => { prompt.handleInput(d); tui.requestRender(); },
        invalidate: () => prompt.invalidate(),
      };
    }, { overlay: true });

    if (result === "session") {
      sessionAllowed.add(sessionKey);
      return;
    } else if (result === "once") {
      return;
    } else {
      return { block: true, reason: "Denied by user" };
    }
  });

  pi.on("session_start", () => {
    sessionAllowed.clear();
  });
}
