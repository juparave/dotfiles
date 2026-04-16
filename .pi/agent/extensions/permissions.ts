import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import {
  Key,
  matchesKey,
  truncateToWidth,
  visibleWidth,
  SelectList,
  type SelectListTheme,
  type Theme,
} from "@mariozechner/pi-tui";
import { resolve, isAbsolute, relative } from "node:path";
import { stat, readFile } from "node:fs/promises";
import { homedir } from "node:os";

// --- Configuration & State ---

const SAFE_COMMANDS = new Set([
  "ls", "pwd", "git status", "git diff", "git log", "head", "tail",
  "echo", "which", "type", "du", "df", "ps aux"
]);

// Shell operators that could chain unsafe commands after a safe one
const SHELL_OPERATORS = /[;&|`$(){}]/;

const SENSITIVE_PATTERNS = [
  /\.env(\.|$)/, /\.ssh/, /\/etc\//, /\.aws/, /secret/i,
  /api[_-]?key/i, /\.pem$/, /\.key$/, /token/i, /password/i, /credential/i,
];

// Session-level trust for non-bash tools: keyed by tool name.
const sessionAllowedTools = new Set<string>();

// Session-level trust for bash: keyed by command stem (base + first non-flag subcommand).
// e.g. "npm run build" → "npm run", "git commit -m ..." → "git commit", "ls -la" → "ls"
const sessionAllowedBash = new Set<string>();

function getBashSessionKey(command: string): string {
  const parts = command.trim().split(/\s+/);
  const base = parts[0];
  const sub = parts[1];
  // Include subcommand only if it's a plain word (not a flag, path, or filename)
  if (sub && !sub.startsWith("-") && !sub.includes("/") && !sub.includes(".")) {
    return `${base} ${sub}`;
  }
  return base;
}

// --- UI Components ---

const DIALOG_WIDTH = 64;

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
      scrollInfo: (t) => theme.fg("muted", t),
      noMatch: (t) => theme.fg("muted", t),
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
    // Vim-style navigation
    if (matchesKey(data, "j")) { this.list.handleInput?.("\x1b[B"); return; }
    if (matchesKey(data, "k")) { this.list.handleInput?.("\x1b[A"); return; }
    this.list.handleInput?.(data);
  }

  render(width: number): string[] {
    // Inner content width = total - 2 borders - 2 padding spaces
    const innerWidth = Math.max(0, width - 4);
    const b = (t: string) => this.theme.fg("borderAccent", t);

    // Wrap a line in border + background
    const row = (line: string) => {
      const truncated = truncateToWidth(line, innerWidth);
      const padLen = Math.max(0, innerWidth - visibleWidth(truncated));
      const padded = this.theme.bg("customMessageBg", truncated + " ".repeat(padLen));
      return b("│") + " " + padded + " " + b("│");
    };

    // Top border with title embedded
    const titleLabel = " Permission Request ";
    const fillLen = Math.max(0, width - 2 - titleLabel.length);
    const leftFill = Math.floor(fillLen / 2);
    const rightFill = fillLen - leftFill;
    const top = b("┌" + "─".repeat(leftFill)) + this.theme.fg("warning", titleLabel) + b("─".repeat(rightFill) + "┐");
    const bottom = b("└" + "─".repeat(width - 2) + "┘");

    const lines: string[] = [top, row("")];

    // Tool name in warning color
    lines.push(row(this.theme.fg("warning", `⚠  ${this.toolName}`)));
    lines.push(row(""));

    // Details
    for (const d of this.details) {
      lines.push(row(this.theme.fg("text", d)));
    }
    lines.push(row(""));

    // Keyboard hint
    lines.push(row(this.theme.fg("muted", "[1] once  [2] session  [3] deny")));
    lines.push(row(""));

    // SelectList
    for (const l of this.list.render(innerWidth)) {
      lines.push(row(l));
    }

    lines.push(row(""), bottom);
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
    const home = process.env.HOME || homedir();
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

    // 1. Check Session Permissions
    if (isToolCallEventType("bash", event)) {
      if (sessionAllowedBash.has(getBashSessionKey(event.input.command))) return;
    } else if (sessionAllowedTools.has(toolName)) {
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
    }, {
      overlay: true,
      overlayOptions: {
        width: DIALOG_WIDTH,
        anchor: "center",
        margin: 2,
      },
    });

    if (result === "session") {
      if (isToolCallEventType("bash", event)) {
        sessionAllowedBash.add(getBashSessionKey(event.input.command));
      } else {
        sessionAllowedTools.add(toolName);
      }
      return;
    } else if (result === "once") {
      return;
    } else {
      return { block: true, reason: "Denied by user" };
    }
  });

  pi.on("session_start", () => {
    sessionAllowedTools.clear();
    sessionAllowedBash.clear();
  });
}
