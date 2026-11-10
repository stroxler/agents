---
name: pyrefly-visual-review
description: Build an interactive, evidence-labeled visual explanation of Pyrefly code for reviews or bug-root-cause investigation. Use when the user wants to understand a Rust diff through a concrete Python example, asks for a data-flow trace or inline code commentary, or finds a small change unreadable inside a large function. Keep the Python example beside the Rust analysis state; produce a self-contained HTML page, not a wall of prose. A diff is optional.
---

# Pyrefly visual review

Help a human reconstruct enough of the surrounding computation to evaluate a
change. The output is a small, interactive code-reading surface, not a verdict
that substitutes for understanding. Pyrefly is the primary domain: pair the
**Python program being analyzed** with the **Rust checker state** throughout.

This is an experimental workflow sketch. Its first example is
[`examples/pyrefly-5555/`](examples/pyrefly-5555/README.md). Treat that page as an
example to learn from, not a general renderer or a fixed schema.

## Working loop

1. **Pin the source.** Read the requested PR/commit and exact code, including
   surrounding implementation and tests. Record file paths, revisions, and line
   ranges. Use repository instructions and its supported search/build tools.
2. **Pick the explanatory Python case.** Start with the relevant existing test
   or a minimal reproduction. Keep its annotations and call syntax: these are
   checker inputs, not decoration. Add only edge cases that illuminate this
   change. Distinguish introduced problems from preexisting limitations.
3. **Reconstruct the context.** Identify the enclosing function, why control
   reaches the changed branch, variable construction and mutation sites, the
   immediate consumer of the changed value, and the caller's next steps.
   Read beyond the hunk until that causal chain is understood. A boolean in a
   `match` arm can be as important as a function return.
4. **Trace the data.** Sketch compact, Rust-like states at a few meaningful
   steps. Show what changes and what does not. Verify observations with focused
   tests where feasible; retain provenance and limitations. Do not invent a
   debugger recording when the trace is reconstructed from source.
5. **Build the reading surface.** Keep Python, the relevant Rust excerpt, the
   current state, and its explanation together. Use the presentation contract
   below. Read [references/presentation.md](references/presentation.md) when
   designing the page and [references/evidence.md](references/evidence.md)
   before labeling a trace or publishing it.
6. **Check and deliver.** Exercise case switching, stepping, definition
   hover/pinning, source links, and small-screen layout. Check JavaScript errors
   and both color themes. Give the page and a short list of material findings;
   keep detailed explanations on the page. State unverified behavior explicitly.

For review, preserve the project's normal review bar (correctness, clarity,
performance of unaffected paths, and feature ownership). For investigation,
show the causal failure path without manufacturing a before/after diff.
Do not broaden implementation scope, post review comments, contact authors,
install the skill, or merge code unless the user requested that action.

## Presentation contract

- **Python stays visible.** Highlight the current call/expression in the trace
  panel. Do not require scrolling back to a separate test or PR to remember
  which program is being analyzed. Full fixtures and runtime witnesses can fold.
- **State resembles code.** Prefer `Star { prefix: [], middle: int, ... }`,
  `param: None`, or small maps over verbose Rust debug dumps. Use actual field
  names where possible. Mark simplified notation and omitted fields. Highlight
  changed fields; never animate state transitions the code does not perform.
- **Explain scope and continuation.** Name the enclosing function and output
  contract for every code lens. Provide a short tour: input construction →
  branch reachability/nesting → value consumer → subsequent analysis. Separate
  return values from diagnostic/inference side effects.
- **Link code and data.** Hover or focus a variable to reveal its current value,
  definition, mutation site, and purpose. Clicking pins the explanation; touch
  and keyboard users need equivalent controls. Pull nonadjacent definitions
  into the page so external navigation is an escape hatch, not a prerequisite.
- **Make differences legible.** Use readable red/green backgrounds and `−`/`+`
  markers for removed/added code. Keep both versions available without crossing
  out the removed code. Color denotes revision, not correctness: added code
  can be wrong. Show before/after decisions and downstream consequences.
- **Provide real navigation.** Link the whole file, enclosing function, current
  excerpt, relevant caller, and individual source lines at pinned revisions.
  Preserve real line numbers and visibly mark omitted code.
- **Use progressive disclosure.** Put enough causal context on the main screen;
  fold full fixtures, long definitions, auxiliary shapes, and evidence details.
  Avoid dumping the enormous enclosing function or replacing it with prose.
- **Keep it lightweight.** A standalone HTML page with inline data and scripts
  is the default. No server, credentials, telemetry, network fetches, eval, or
  storage are needed for a source sketch. Adapt theme and publishing to the
  host; do not make a public example depend on private services.

## Pyrefly-specific distinctions

The Python example is not a runtime input to the Rust program. The checker may
see `xs: list[int]` while a runtime witness uses `xs = []`; these are different
levels of evidence. Do not claim `forward([])` specializes `forward`'s body.
Likewise separate argument-binding state, type constraints, diagnostics, and
inferred Python result types. Error removal can affect overload selection.

Trace abstraction boundaries explicitly: a union may lose shape information;
a type variable can become constrained without being solved; a failed check
can still mutate a matching cursor. Read the code rather than assuming that
field names, comments, or an apparently successful output prove an invariant.

## Iteration

Keep the skill small until multiple examples justify shared machinery. Preserve
examples and feedback as reproducible inputs, not screenshots alone. The
[`evals/evals.json`](evals/evals.json) prompts cover this PR, a no-diff
investigation, and a different Pyrefly subsystem. They are proposed exercises,
not measured benchmark results. Human evaluation asks: can the reader explain
why this branch runs, what state it sees, and what its value changes without
leaving the page?
