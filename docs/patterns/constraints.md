# Constraint-Based Prompting

## Philosophy

Adding constraints improves output quality by preventing over-engineering and maintaining focus. Counter-intuitively, constraints lead to better solutions.

## Default Template

```
Task: [specific goal]
Constraints:
- Minimal necessary changes only
- Use existing patterns from [specific files]
- Single file modification if possible
- No new dependencies

Plan first, confirm before implementation.
```

## Why This Works

1. **Prevents Over-Engineering**: Forces simplicity
2. **Maintains Consistency**: Aligns with existing patterns
3. **Reduces Cognitive Load**: Clearer scope
4. **Faster Implementation**: Less code to write/review

## Examples

### Good Constraints
- "Make minimal changes to accomplish this"
- "Use the existing authentication pattern from auth/service.py"
- "Modify only the user model, no other files"
- "Use built-in library features, no new packages"

### Poor Constraints (Too Vague)
- "Make it good"
- "Follow best practices"
- "Keep it simple"

## Application

Apply constraints by default. Challenge complexity. Ask:
- "What's the minimum change that solves this?"
- "Does this align with existing patterns?"
- "Am I adding unnecessary abstraction?"
