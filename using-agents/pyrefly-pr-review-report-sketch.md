# Markdown report sketch

This is an unfilled presentation example for the
[Pyrefly PR review notes](pyrefly-pr-review-notes.md), not an executed review.
Placeholders are deliberate; no code, scores, or traces below are evidence.
Blank lines around Markdown inside `<details>` are intentional.

The first screen has a short change explanation and simplicity/tech-debt verdict.
The following three sections fold independently.

<details open>
<summary>Score: [computed value or bounds]</summary>

Reviewed PR and base/head revisions: [pinned identities].
Recommendation: [review outcome]. Unknowns: [what remains unresolved].

</details>

<details>
<summary>Score breakdown</summary>

[Per-section results from the existing score script.]
[Dimension verdicts and evidence, with links to finding IDs.]

</details>

<details>
<summary>Detailed review notes</summary>

## F1: [Rust factoring concern and its impact]

Comment at **[file, new-side line]**: [jump to exact GitHub Changes-page line].

[New responsibility, existing owner, and why the distinction matters.]

<details>
<summary>Rust evidence: [path], [revision], [side], lines [start-end]</summary>

```text
[original line]  [verbatim Rust source]
[original line]  [verbatim Rust source]
```

[Commit-pinned supporting code showing the existing machinery.]

</details>

Draft comment: [specific request to the author].
Smaller factoring: [concrete proposal or reason it is not viable].
Validation of the proposal: [implemented/tested, source-derived, or not done].

## F2: [Python behavior bug]

```python
# [minimal source reproducer, with necessary annotations/settings]
```

Expected: [behavior]. Observed: [behavior].
Evidence: [test/run/source reasoning and limitations].
Rust localization: [verified cause, suspected region, or not yet localized].
Comment anchor when applicable: [exact GitHub Changes-page link].

<details>
<summary>Rust cause: [path], [revision], [side], lines [start-end]</summary>

```text
[original line]  [verbatim Rust source at the cause]
```

[Enclosing operation, why this example reaches it, and immediate consumer.]

</details>

<details>
<summary>Rust data-state sketch for this Python example</summary>

```text
Step A — [input state: actual fields/variants that matter]
Step B — [state seen by the changed branch]
Step C — [output/state mutation and its consumer]
```

Provenance: [observed / source-derived / hypothesis].
Simplifications: [omitted fields or explanatory notation].
[Explain the connection to the Python behavior, not just control-flow arrows.]

</details>

</details>

Follow-up chat refers to **F1/F2** and supplies a relevant source excerpt or exact
line link. It can expand/update the same evidence section without requiring the
reader to restate which code is under discussion. Nothing here posts PR comments.
