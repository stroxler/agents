# Presentation sketch

The goal is an IDE-like reading surface enriched with causal context. Inspired
by Brett Victor's *Inventing on Principle*: make the relationship between code
and its consequences visible and manipulable. This is a sketch, not a live IDE
or a claim of full execution semantics.

## Main screen

```
case picker / timeline
┌──────────────────────────────┬──────────────────────────────┐
│ function + output contract   │ Python example (active call) │
│ short context tour          │                              │
│ pinned source links         │ Rust-like state at this step │
│ relevant Rust / red-green   │ changed fields / commentary │
│                             │                              │
│ hover / pinned definition   │ value → consumer → outcome   │
└──────────────────────────────┴──────────────────────────────┘
folded full fixtures / auxiliary views / evidence
```

The trace should show actual abstract data, not just boxes labeled with verbs.
For a Pyrefly call matcher, one compact state could be:

```rust
arg_pre: Star {
    prefix: [int, int], middle: int, suffix: [],
    consumed: 1, matched: true, done: false,
}
rparams: []
param: None
```

Explain that these `int` values are Python *types*. Keep essential fields even
when redundant: the conflict between `matched: true` and a mandatory remainder
is important to understand the code. Omit allocator, lifetimes, arena handles,
and formatting noise unless they matter to the behavior.

## Context is more than jump-to-definition

For each important expression answer:

1. What function and control-flow scope contains it?
2. What brought this example here?
3. Where were its inputs defined and changed?
4. What receives its value, or what state does it mutate?
5. What continues after it, and what observable result can that affect?

In PR 5555, the key nesting is:

```rust
for arg in args {
    let mut arg_pre = arg.pre_eval(...);
    while arg_pre.step() {
        let param = /* next positional parameter */;
        match param {
            Some(...) => /* match/check, advance cursor */,
            None => {
                let extra_arg = match arg_pre {
                    Star { ... } => /* changed boolean */,
                    _ => true,
                };
                if extra_arg { /* append source range */ }
                break; // this while, not the enclosing function
            }
        }
    }
}
// Other argument/keyword/missing-parameter analysis continues.
// Return ArgMap; diagnostics were collected separately.
```

This is explanatory pseudocode, not an exact source excerpt. Label it as such;
keep exact, line-numbered excerpts available nearby. False in the inner match
is not a function return or a success verdict.

## Candidate reusable pieces

Keep extraction separate from presentation: source spans and revisions,
context/consumer relationships, example source, snapshots with evidence,
optional revision overlays, and outcomes. Avoid one new concept per UI panel.
Do not freeze a schema or build a parser until a second subsystem and a no-diff
investigation expose what the first example overfits.

The current example contains specialized JavaScript branches. Preserve it as a
learning fixture; do not call it a general library. A future renderer should
consume authored traces rather than guessing Rust execution from syntax.
