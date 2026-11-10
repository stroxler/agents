# Pyrefly PR 5555 example

A preserved, specialized visual review of
[PR 5555](https://github.com/meta/pyrefly/pull/5555), pinned to
`2a215a3bb5880f5f7e94a2d7cb65d12850247c2b`.

## Open it

```
python3 build.py
```

Open the resulting `index.html` in a browser. The page is self-contained: no
server, network calls, browser storage, telemetry, or private services. It has a
light/dark toggle. The generated page is not committed; rebuild it from the
readable source. `template.html` contains the UI and `data.json` the authored
examples, source excerpts, states, commentary, and source links.

This fixture intentionally has specialized case logic. It is the first example
for a workflow skill, not a general renderer API. The useful pattern is the
Python/Rust pairing and causal context, not its particular JSON field names.

## What to try

- Start with the list splat case, then the nonempty-tuple union. They lower to
  identical `Star` states although only the list can be empty.
- Step the mandatory-prefix remainder case to see `consumed` and `matched`
  change. This hole was preexisting, not introduced by the PR.
- Use the four context-tour stops to follow input construction, branch nesting,
  the boolean's immediate consumer, and the caller's continuation.
- Hover a variable and click to pin its definition. Open a pinned source line
  when the excerpt is insufficient. Python stays in the trace panel.

The changed `false` is a value assigned to `extra_arg`, not a function return.
It skips an append; a `break` exits the argument's while loop. The enclosing
function continues checking and eventually returns `ArgMap`, while diagnostics
travel separately through error collectors. The overload example demonstrates
why those side effects matter downstream.

## Evidence limits

States are reconstructed from public source, not debugger recordings.
`cases.py`, `config.toml`, `before.json`, and `after.json` retain historical
inputs and diagnostics from the exact gate applied to another Pyrefly checkout.
That was not an exact GitHub-head build. These output snapshots do not establish
current behavior; rerun against the requested revision for a fresh review.
They cover Linux/default overload mode, not a full suite or primer evaluation.
The runtime witnesses were checked separately.

The browser smoke test exercises the UI, not Pyrefly semantics. Run it from the
skill directory:

```
python3 scripts/check_example.py
# Optional browser check; requires Playwright and its Chromium installation:
python3 scripts/check_example.py --browser
```

## Source licensing

The skill, renderer, and commentary are original material under the repository's
CC0 license. The Rust source excerpts in `data.json` are from Pyrefly and remain
under the MIT license in `LICENSE.pyrefly`. Source links and notices are retained.

## Initial feedback distilled

- Data should resemble a compact debugger state, not only a flowchart.
- Keep the Python program in the trace, even when the implementation is Rust.
- Explain enclosing scope and the consumer of expression values, not only returns.
- Use readable red/green diff blocks, with noncolor cues.
- Offer source navigation, but pull enough context inline to make it optional.
