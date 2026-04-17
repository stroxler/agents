# gemini-cli

Use this skill when you want an additional independent opinion from Gemini while keeping Codex as the primary driver.

## When to use

Use for:
- Plan review and alternative framing
- Implementation review and regression hunting
- Debugging hypotheses and concise conceptual explanations

Avoid for:
- Tasks where a second model perspective is unnecessary
- Tasks requiring Gemini tool execution in your workspace

## Operating model

- Codex remains the lead agent.
- Codex decides framing dynamically based on current context.
- Gemini is used as an independent reviewer during planning and implementation loops.
- Codex integrates or rejects Gemini feedback with explicit reasoning.

## Guardrails

- Gemini support quality can vary by environment and setup.
- Give Gemini highly specific prompts with scoped context included directly in the prompt.
- Do not rely on Gemini to navigate large codebases or external tooling on its own.
- Prefer Gemini for high-level thinking, concise conceptual explanations, and straightforward review questions.
- Avoid open-ended or execution-oriented asks (for example: broad repo exploration, multi-step implementation, or tool-heavy workflows).
- Keep Codex responsible for concrete execution and integration.

## Wrapper location

`~/.llms/skills/gemini-cli/gemini-wrapper.sh`

## Usage patterns

### Ask Gemini a focused question
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --full-log "Challenge this migration plan"
```

### Review uncommitted changes
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --review --uncommitted --full-log "Find correctness risks and missing tests"
```

### Review against a base branch
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --review --base main --full-log "Review for regressions"
```

### Review a specific commit or revision
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --review --commit HEAD --full-log "Audit this change"
```

### Resume a previous Gemini session
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --resume <session-id> --full-log "Follow up on finding #2"
```

### Set model explicitly
```bash
~/.llms/skills/gemini-cli/gemini-wrapper.sh --model gemini-3-flash-preview --full-log "Stress-test this architecture"
```

## Output format

The wrapper prints:
1. A metadata header with `session_id`, `exit_code`, and optional `full_log`
2. The clean Gemini response text

## Notes

- Wrapper uses `gemini -o stream-json -p` for stable event parsing.
- For conversational continuity, use `--resume <session-id>`.
- Logs default to `/tmp/gemini-logs/` and can be overridden with `GEMINI_LOG_DIR`.

## Minimal Codex loop

1. Ask Gemini for a second opinion with current context.
2. Evaluate and integrate (or reject) findings in Codex.
3. Continue same Gemini thread via `--resume <session-id>` if follow-up is needed.
