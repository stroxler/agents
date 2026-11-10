# Visual execution sketches

A Pyrefly-first experiment in making code review and bug investigation easier
to understand. Keep the Python example, Rust analysis state, surrounding code
context, and observable consequence together in a lightweight reading surface.

The starting point is the
[`pyrefly-visual-review` skill](../../dot-agents/skills/pyrefly-visual-review/SKILL.md)
and its [PR 5555 example](../../dot-agents/skills/pyrefly-visual-review/examples/pyrefly-5555/README.md).
The example is a working, specialized prototype—not a generic JavaScript library.

## Next iteration

1. Use the skill on a second Pyrefly subsystem and on a no-diff root cause.
2. Ask whether a reader can explain branch reachability, current state, and
   downstream consequences without leaving the page.
3. Extract the smallest shared renderer supported by those examples. Keep
   Python/Rust pairing and checker semantics separate from general source,
   context, trace, and optional-diff presentation.

Initial boundaries: authored/reconstructed traces, not arbitrary Rust execution;
pinned source links, not full IDE navigation; evidence labels, not proof of
correctness. Preserve fast paths and conceptual simplicity as this evolves.
