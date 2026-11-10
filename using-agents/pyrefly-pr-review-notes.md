# Pyrefly PR review: notes for a visual skill

Status: requirements sketch, not an installable skill or renderer implementation.

## Purpose and starting point

Help a maintainer understand a PR and return actionable feedback without
reconstructing its Rust machinery from a wall of text or external links.

Start from Rebecca's existing
[`score-pyrefly-change`](https://github.com/meta/pyrefly/blob/b738752eff2a89b61fd1ba65b260c81acceb1d67/.agents/skills/score-pyrefly-change/SKILL.md),
including its
[score script](https://github.com/meta/pyrefly/blob/b738752eff2a89b61fd1ba65b260c81acceb1d67/.agents/skills/score-pyrefly-change/scripts/score.py)
and [report template](https://github.com/meta/pyrefly/blob/b738752eff2a89b61fd1ba65b260c81acceb1d67/.agents/skills/score-pyrefly-change/assets/template.md).
Keep its review procedure, evidence requirements, neutral base-only analyses,
verdicts, and score computation. Presentation must not silently change findings
or rescore them. These links pin the starting point, not a permanently frozen
upstream version.

The separate [visual-execution experiment in PR #1](https://github.com/stroxler/agents/pull/1)
explores Python/Rust causal traces. These notes complement it with a scorecard
review and comment-ready evidence; they do not modify or duplicate that renderer.

## First screen and disclosure

- Lead with what changes for users and the simplicity/tech-debt verdict.
- Keep the score, its per-section breakdown, and detailed review notes in
  independently collapsible sections. Do not interleave their long explanations.
- Keep the report off to the side, openable as a full page. Keep chat available
  for questions about the selected finding, code excerpt, or trace step.
- Use stable finding IDs so a follow-up can refer to the same evidence.
- Produce independent, revision-pinned reports for parallel PRs; do not require
  one shared IDE session or a long-lived checkout to read them.

The [Markdown report sketch](pyrefly-pr-review-report-sketch.md) shows the intended
folds and evidence slots. It is a template, not a scored review.

## Evidence that travels with each finding

**Poorly factored Rust:** identify the new responsibility or duplicate machinery,
not merely the number of helpers, mutable variables, or `extend` calls. Include:

1. A specific changed-line comment anchor and clickable GitHub Changes-page link.
2. A folded, verbatim Rust excerpt with original source line numbers, file,
   revision, and old/new side. Make code omissions explicit.
3. The existing machinery that could absorb the work, with its own source evidence.
4. Draft line-comment wording and a concrete smaller factoring to investigate,
   or evidence explaining why the extra machinery is necessary. Label an
   unimplemented proposal as a proposal, not a tested fix.

The reviewer owns this investigation. A vague "could simplify" note that makes
the maintainer discover the factoring is unfinished review work.

**Python behavior bugs:** include the Python reproducer, expected and observed
behavior, relevant settings, and validation provenance. Pair it with a localized
Rust cause when one can be established: a folded, numbered source excerpt and
Changes-page link, plus the enclosing operation and immediate consumer. If the
cause is uncertain, distinguish the suspected region from a verified cause; if
it is not localizable, say so rather than manufacturing a line comment.

**Rust data flowing through a bug:** where useful, add a separate folded sketch
of concrete Rust-like states for the Python example. Show input construction,
the changed branch's relevant fields/variants, and what consumes its output.
A boxes-and-arrows call graph alone is not a state trace. Label simplified or
omitted fields, and distinguish observed values, source-derived states, and
hypotheses. Do not present a reconstruction as a debugger recording or conflate
Python runtime values with the checker's inferred types.

## Source anchors

A code reference carries `(repository, PR, base/head revision, path, side,
start line, end line)` and the exact excerpt. Never find the target by searching
for display text such as `: int`, or renumber an excerpt from 1.

For an ordinary new-side GitHub diff anchor, the candidate URL is:

```text
https://github.com/OWNER/REPO/pull/NUMBER/changes#diff-SHA256_PATHRLINE
```

Here `SHA256_PATH` is the lowercase SHA-256 digest of the UTF-8 repository-relative
file path, and `LINE` is the original new-side line number. Old-side anchors use
`L`. Verify the rendered anchor when possible, particularly for renamed files;
label unverified navigation. When unchanged supporting code is outside the diff,
use a commit-pinned blob link instead. Never pretend it is a commentable PR line.
If the PR head moves, keep the reviewed revision visible and refresh the mapping
before presenting a comment as ready to post.

## Chat follows the same evidence contract

Follow-up explanations should include the relevant numbered Rust excerpt and/or
an exact GitHub Changes-page link, not just a verbal description. Keep substantial
code off to the side when possible and identify the selected finding/step in chat.
Show where a conceptual diagram maps to actual code and where feedback can be
left. Drafting feedback does not authorize posting comments or contacting authors.

## Smallest implementation and open questions

Try GitHub-flavored Markdown with reusable `<details>` / `<summary>` patterns
first. A small fixed vocabulary is enough: overview/score, finding, source
excerpt, Python reproducer, and Rust-state trace. Review agents supply evidence;
they should not invent a different layout for every PR.

Only if Markdown cannot meet the reading/context needs, explore a small reusable
HTML/widget renderer over the same evidence. Embed pinned source snapshots;
avoid live authenticated code fetches, a new review engine, or speculative
Rust-execution simulation. Do not extract a generic UI library until examples
show what actually needs reuse.

Future checks: exercise the folds and exact source anchors in the target host;
compare readability on a factoring finding and a Python bug with a local Rust
cause; check a bug whose cause is not localizable; and try chat follow-ups that
retain the selected evidence. Renderer choice and state-sketch notation remain
open. This PR collects notes only.
