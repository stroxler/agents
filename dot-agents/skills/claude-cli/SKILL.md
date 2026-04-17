# claude-cli

Use this skill when you want a second opinion from Claude while keeping Codex as the primary driver.

## When to use

Use for:
- Design/plan review
- Implementation review
- Debugging hypotheses and alternative root-cause analysis
- Sanity-checking risky refactors
- Integration-heavy investigations where Claude's tool/connector support is needed

Avoid for:
- Work that can be done directly in Codex without independent perspective
- Tasks that require Claude tool execution in your workspace (this wrapper disables Claude tools by default)

## Operating model

- Codex remains the lead agent.
- Codex decides how to frame the question to Claude based on current context.
- Claude is used as an independent reviewer, especially in:
  - Planning cycles (challenge assumptions, surface missing risks/tests).
  - Implementation loops (spot regressions, edge cases, debugging gaps).
- For tasks requiring deep integration context, prefer delegating to Claude.
- Codex integrates or rejects Claude feedback with explicit reasoning.

## Permission guardrails

- Default runs should keep normal permissions.
- If a task needs broader tool access, opt in with:
  `--unsafe-permissions`
- `--unsafe-permissions` maps to:
  `--allow-dangerously-skip-permissions --dangerously-skip-permissions`
- Use this only in trusted environments.

## Wrapper location

`~/.llms/skills/claude-cli/claude-wrapper.sh`

## Usage patterns

### Ask Claude a focused question
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --full-log "Review this approach for race conditions"
```

### Review uncommitted changes
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --review --uncommitted --full-log "Find correctness risks and missing tests"
```

### Review against a base branch
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --review --base main --full-log "Review for regressions"
```

### Review a specific commit or revision
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --review --commit HEAD --full-log "Audit this change"
```

### Resume a previous Claude session (required for ongoing conversation)
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --resume <session-id> --full-log "Follow up on finding #2"
```

### Set model and effort explicitly
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --model sonnet --effort high --full-log "Stress-test this migration plan"
```

### Integration-heavy task (trusted env only)
```bash
~/.llms/skills/claude-cli/claude-wrapper.sh --unsafe-permissions --full-log "Investigate why this service call is failing"
```

## Output format

The wrapper prints:
1. A metadata header with `session_id`, `exit_code`, and optional `full_log`
2. The clean Claude response text

## Notes

- Wrapper uses `claude -p --output-format json` for stable parsing.
- For conversational continuity, always use `--resume <session-id>`.
- Logs default to `/tmp/claude-logs/` and can be overridden with `CLAUDE_LOG_DIR`.
- No fixed prompt template is required; framing is intentionally left to Codex.

## Minimal Codex loop

1. Ask Claude for a second opinion with current context.
2. Evaluate and integrate (or reject) findings in Codex.
3. Continue same Claude thread via `--resume <session-id>` if follow-up is needed.
