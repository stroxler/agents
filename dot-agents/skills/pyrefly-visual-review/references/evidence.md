# Evidence boundaries

Label each state or result according to how it was obtained:

- **Recorded:** captured by instrumentation or a debugger from the stated run.
- **Reconstructed:** derived by following the pinned source for the example.
- **Observed output:** produced by a checker/test command, with revision,
  configuration, platform, and reproduction input retained.
- **Hypothesis:** a plausible unverified path; do not describe it as a finding.

A reconstructed internal trace and observed diagnostics can coexist. The
observed output does not prove that every reconstructed intermediate state is
accurate. Show source links and invariants so readers can audit the reasoning.

## Before/after work

Use the same input and settings, changing only the revision or proposed patch.
State whether the build is exact PR head or a patch applied to another base.
Save commands and semantic output; avoid brittle temporary paths. Report build
failures as verification gaps, not code defects, until reproduced reliably.

Keep runtime witnesses separate from the type checker's inputs. A nonempty
Python tuple can demonstrate a runtime exception without establishing the
checker's abstract representation; that representation needs source or trace
evidence. An accepted call is not proof that all runtime lengths are safe.

## Public examples

Publish only content authorized for that destination. Strip credentials,
internal hosts, private artifact links, internal-only code, local user paths,
and unrelated personal data. Read public code at its public revision rather
than exporting nearby internal implementation. Preserve licenses and attribution
for source excerpts. A screenshot can leak the same content as its source.

If the host cannot publish safely, preserve a local deliverable or use an
approved private artifact route; do not fall back to public hosting.

## Validation

Check state mutations against source, especially cursor movement, early exits,
error-collector side effects, and loss of information at normalization. State
whether a case is introduced, preexisting, intentional policy, or unresolved.

UI checks should cover no-script first content, all cases and steps, hover and
pin/unpin, keyboard/touch fallbacks, source links, theme contrast, and mobile
width. A sandbox smoke test is not a signed-in production-host test. Put exact
limits in the deliverable rather than claiming full coverage.
