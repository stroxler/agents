# codex

Use this skill when you want an independent opinion from Codex (OpenAI) while keeping another agent as the primary driver.

## When to use

Use for:
- Design/plan review and alternative framing
- Implementation review and regression hunting
- Debugging hypotheses and root-cause analysis
- Sanity-checking risky refactors

Avoid for:
- Work that can be done directly without an independent perspective
- Tasks that don't benefit from a second model's viewpoint

## Operating model

- The calling agent remains the lead.
- The lead agent decides how to frame the question to Codex based on current context.
- Codex is used as an independent reviewer during planning and implementation loops.
- The lead agent integrates or rejects Codex feedback with explicit reasoning.
- For ongoing conversations, always resume with `--resume <session-id>` to maintain context.

## Wrapper location

`~/.llms/skills/codex/codex-wrapper.sh`

## Usage patterns

### Ask Codex a focused question
```bash
~/.llms/skills/codex/codex-wrapper.sh --full-log "Review this approach for race conditions"
```

### Review uncommitted changes
```bash
~/.llms/skills/codex/codex-wrapper.sh --review --uncommitted --full-log "Find correctness risks and missing tests"
```

### Review against a base branch
```bash
~/.llms/skills/codex/codex-wrapper.sh --review --base main --full-log "Review for regressions"
```

### Review a specific commit or revision
```bash
~/.llms/skills/codex/codex-wrapper.sh --review --commit HEAD --full-log "Audit this change"
```

### Resume a previous Codex session (required for ongoing conversation)
```bash
~/.llms/skills/codex/codex-wrapper.sh --resume <session-id> --full-log "Follow up on finding #2"
```

### Select a specific model
```bash
~/.llms/skills/codex/codex-wrapper.sh --model o3 --full-log "Stress-test this migration plan"
```

### Full-auto mode (trusted env only)
```bash
~/.llms/skills/codex/codex-wrapper.sh --full-auto --full-log "Investigate why this test is flaky"
```

## Output format

The wrapper prints:
1. A metadata header with `session_id`, `exit_code`, and optional `full_log`
2. The clean Codex response text

## Notes

- Wrapper uses `codex exec` with `--json` for stable JSONL parsing.
- For conversational continuity, always use `--resume <session-id>`.
- Logs default to `/tmp/codex-logs/` and can be overridden with `CODEX_LOG_DIR`.
- Sessions are persisted by default; use `--ephemeral` for throwaway queries.

## Minimal loop

1. Ask Codex for a second opinion with current context.
2. Evaluate and integrate (or reject) findings in the lead agent.
3. Continue same Codex thread via `--resume <session-id>` if follow-up is needed.
