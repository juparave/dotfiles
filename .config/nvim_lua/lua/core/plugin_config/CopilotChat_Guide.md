# CopilotChat for Neovim: Real-World Usage Guide

A comprehensive guide to using CopilotChat effectively in your daily development workflow.

## 🚀 Quick Start

### Basic Usage
```vim
" Open chat window
<leader>cc

" Quick chat with prompt
<leader>cq
```

### Visual Selection Workflow
1. Select code in visual mode (`v` or `V`)
2. Press `<leader>cc` to chat with selection
3. Ask questions about the selected code

## 📋 Key Bindings Reference

| Mode | Keybinding | Action | Description |
|------|------------|--------|-------------|
| Normal | `<leader>cc` | Open Chat | Opens the chat window |
| Visual | `<leader>cc` | Chat with Selection | Opens chat with visual selection |
| Normal | `<leader>cq` | Quick Chat | Prompt for quick question |
| Normal/Visual | `<leader>ce` | Explain Code | Explains current buffer/selection |
| Normal/Visual | `<leader>ct` | Generate Tests | Creates tests for code |
| Normal/Visual | `<leader>cr` | Review Code | Reviews code for issues |
| Normal/Visual | `<leader>cf` | Fix Code | Suggests fixes for problems |
| Normal | `<leader>co` | Optimize Code | Suggests performance improvements |
| Normal | `<leader>cd` | Add Documentation | Generates documentation |
| Normal | `<leader>cm` | Commit Message | Generates git commit message |
| Normal | `<leader>cp` | Browse Prompts | Opens prompt selector |
| Normal | `<leader>ch` | Help | Shows help information |

## 🎯 Real-World Examples

### 1. **Code Review and Refactoring**

#### Scenario: You inherit legacy JavaScript code
```javascript
// Legacy code that needs review
function processData(data) {
    var result = [];
    for (var i = 0; i < data.length; i++) {
        if (data[i].status == 'active') {
            result.push({
                id: data[i].id,
                name: data[i].name.toUpperCase(),
                processed: true
            });
        }
    }
    return result;
}
```

**Workflow:**
1. Select the function with `V` (visual line mode)
2. Press `<leader>cr` (review code)
3. Ask: "What are the potential issues with this code and how can it be improved?"

**Expected suggestions:**
- Use `const/let` instead of `var`
- Use `===` instead of `==`
- Consider using `filter()` and `map()` for functional approach
- Add error handling for edge cases

### 2. **Understanding Complex Code**

#### Scenario: Working with unfamiliar React hooks
```javascript
const useDebounce = (value, delay) => {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    
    return () => clearTimeout(handler);
  }, [value, delay]);
  
  return debouncedValue;
};
```

**Workflow:**
1. Select the hook with visual mode
2. Press `<leader>ce` (explain code)
3. CopilotChat will explain how debouncing works, useEffect cleanup, and when to use this hook

### 3. **Test Generation**

#### Scenario: Need tests for a utility function
```python
def calculate_discount(price, discount_percent, max_discount=None):
    """Calculate discounted price with optional maximum discount."""
    if discount_percent < 0 or discount_percent > 100:
        raise ValueError("Discount percent must be between 0 and 100")
    
    discount_amount = price * (discount_percent / 100)
    
    if max_discount and discount_amount > max_discount:
        discount_amount = max_discount
    
    return price - discount_amount
```

**Workflow:**
1. Select the function
2. Press `<leader>ct` (generate tests)
3. Get comprehensive test cases including edge cases

**Generated test structure:**
- Valid discount calculations
- Edge cases (0%, 100% discount)
- Error cases (negative discount, > 100%)
- Maximum discount limit scenarios

### 4. **Bug Fixing**

#### Scenario: Function with subtle bug
```javascript
function findUserById(users, id) {
    for (let user of users) {
        if (user.id == id) {  // Bug: should use ===
            return user;
        }
    }
    return null;
}
```

**Workflow:**
1. Select problematic code
2. Press `<leader>cf` (fix code)
3. Get explanation of type coercion issue and strict comparison fix

### 5. **Documentation Generation**

#### Scenario: Undocumented API function
```typescript
function validateEmailAndSendNotification(email: string, template: string, data: object) {
    if (!isValidEmail(email)) {
        throw new Error('Invalid email format');
    }
    
    const notification = buildNotification(template, data);
    return sendEmail(email, notification);
}
```

**Workflow:**
1. Select the function
2. Press `<leader>cd` (add documentation)
3. Get proper JSDoc/TSDoc comments with parameter descriptions

### 6. **Git Commit Messages**

#### Scenario: Staged changes need a commit message
```bash
# You've made changes and staged them
git add .
```

**Workflow:**
1. In Neovim, press `<leader>cm` (commit message)
2. Get a properly formatted commit message following conventional commits

**Example output:**
```
feat(auth): add email validation to user registration

- Implement email format validation using regex
- Add error handling for invalid email addresses
- Update user registration flow to validate before processing
- Add unit tests for email validation function

Closes #123
```

## 🔧 Advanced Workflows

### Context-Aware Questions

Use the `#` syntax to provide context:

```
#buffer
#files:*.js
#git:staged

How can I improve the error handling across these files?
```

### Sticky Prompts

Add persistent context that stays across chat sessions:

```
> I'm working on a React TypeScript project
> Please suggest TypeScript-specific solutions
> Follow React best practices

Explain this component's lifecycle
```

### Custom Prompts

In chat, you can create reusable prompts:

```
/Architect Analyze this code from a system architecture perspective. Consider:
- Scalability concerns
- Maintainability issues  
- Performance implications
- Security considerations
```

## 💡 Pro Tips

### 1. **Iterative Development**
- Start with `<leader>cq` for quick questions
- Use `<leader>ce` to understand existing code before modifying
- Apply `<leader>cf` after making changes to catch issues

### 2. **Code Review Process**
```
1. Select function/class
2. <leader>cr (review)
3. Address suggestions
4. <leader>ct (generate tests)
5. <leader>cm (commit message)
```

### 3. **Learning New Technologies**
- Select unfamiliar code patterns
- Use `<leader>ce` to get explanations with examples
- Ask follow-up questions about alternatives and best practices

### 4. **Debugging Workflow**
- Select problematic code
- Ask: "What could cause this function to fail?"
- Follow up with: "How would you debug this step by step?"

### 5. **Performance Optimization**
- Select performance-critical code
- Use `<leader>co` for optimization suggestions
- Ask about specific concerns: "How can I reduce memory usage here?"

## 🎪 Chat Window Features

### In-Chat Navigation
- `q` - Close chat window
- `<C-l>` - Clear chat history
- `<CR>` - Submit prompt (normal mode)
- `<C-s>` - Submit prompt (insert mode)
- `<C-y>` - Accept suggested code changes

### Special Commands in Chat

#### Context Commands
```
#buffer           - Include current buffer
#buffers          - Include all open buffers  
#file:path/to/file - Include specific file
#files:*.py       - Include files matching pattern
#git:staged       - Include staged git changes
#git:unstaged     - Include unstaged changes
```

#### Model Selection
```
$gpt-4o          - Use GPT-4o model
$gpt-3.5-turbo   - Use GPT-3.5 model
```

## 🚨 Common Mistakes to Avoid

### 1. **Too Vague Questions**
❌ "Fix this code"
✅ "This function is throwing a null pointer exception when processing empty arrays. How can I add proper error handling?"

### 2. **Not Providing Context**
❌ "How do I optimize this?"
✅ "This function processes 10k+ records and is slow. How can I optimize for better performance?" (with code selected)

### 3. **Ignoring Visual Selection**
❌ Asking about "this function" without selecting it
✅ Select the specific code block before asking questions

### 4. **Not Following Up**
❌ Accepting first suggestion without clarification
✅ Ask follow-up questions: "Why is this approach better?" "Are there any trade-offs?"

## 📈 Productivity Hacks

### Daily Workflow Integration
```bash
# Morning routine
1. <leader>cc - Check for any code reviews from yesterday
2. Review staged changes with <leader>cm before committing
3. Use <leader>ce on any unfamiliar code encountered

# During development
1. <leader>cq for quick syntax questions
2. <leader>ct after writing new functions
3. <leader>cr before submitting PRs

# End of day
1. <leader>cm for clean commit messages
2. Document complex logic with <leader>cd
```

### Project-Specific Setup
Create project-specific prompts by adding to your chat:

```
> This is a Next.js 14 project using TypeScript
> We follow Airbnb ESLint rules
> We use Tailwind CSS for styling
> Suggest solutions that fit our tech stack
```

## 🔗 Integration with Other Tools

### With Git
```bash
# Before committing
git add .
# In Neovim: <leader>cm to generate commit message
git commit -m "generated message"
```

### With Testing Frameworks
1. Write function
2. `<leader>ct` to generate tests
3. Copy tests to test file
4. Run test suite

### With Code Review
1. Select code in PR
2. `<leader>cr` for review
3. Address suggestions
4. Document changes with `<leader>cd`

## 🎓 Learning Path

### Beginner (Week 1)
- Master basic chat (`<leader>cc`, `<leader>cq`)
- Use code explanation (`<leader>ce`) daily
- Practice visual selection workflow

### Intermediate (Week 2-3)
- Integrate test generation (`<leader>ct`) into workflow
- Use code review (`<leader>cr`) before commits
- Start using context commands (`#buffer`, `#files`)

### Advanced (Week 4+)
- Create custom prompts and workflows
- Use sticky prompts for project context
- Integrate with git workflow (`<leader>cm`)
- Develop debugging methodology with CopilotChat

---

## 📚 Additional Resources

- [CopilotChat GitHub Repository](https://github.com/CopilotC-Nvim/CopilotChat.nvim)
- [Neovim Documentation](https://neovim.io/doc/)
- [GitHub Copilot Best Practices](https://docs.github.com/en/copilot)

---

**Remember**: CopilotChat is a tool to enhance your development process, not replace your critical thinking. Always review and understand the suggestions before implementing them in production code.
