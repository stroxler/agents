# Philosophy and Flow

## Human is the driver

To me, the biggest single issue with using coding agents is actually handling
the human factor. Agents can make a lot of mistakes, but the biggest risk is that
as long as a human has to be involved, our ability to keep track of what is going
on and also maintain motivation is a critical bottleneck to any quality. And our
ability to learn determines the frontier of what we can attempt.

I've seen a few interviews with Jeremy Howard, who has built an AI platform
SolveIt (which he would describe as non-agentic; the AI is deeply integrated,
but is closer to a pure chatbot by default who can see what you are doing
and advise), who has thought a lot about this issue. I don't necessarily agree
with Howard that something like SolveIt is the right surface for all software
development - I do use agents - but I think his overall perspective is valuable.

Howard emphasizes both the human need to fully understand the core of what's
happening in order to effectively direct and design, and the fact that progress
requires the human to be continuously learning about the domain, which
agent-first workflows can put at risk.

On top of that, Howard also argues that LLMs are not capable of building software;
his argument is that under the hood, it's still just a curve-fitting next-token
predictor and as a result it is good at exactly the same thing as any other
statistical model: in-distribution interpolation. He argues (or I would) that
*coding* is almost entirely in-distribution if the design/algorithm are
sufficiently specified given the amount of code available, but that the actual
*design* of any genuinely innovative software (including any novel algorithm)
is always out of distribution. As a result, he's skeptical that an aggressively
human-on-the-loop approach can ever produce something very innovative. Hence some
of why he's so convinced that finding ways to use AI in a way where humans remain
engaged, aware of the entire core workstream, and can keep learning is key.

I noticed that an agentic platform developer advocate had a talk that actually
overlapped a bit which is interesting since the actual platform itself is
opposite. In particular this speaker emphasized not allowing agents to have
opinions, and never substituting agent judgment for your own. This is at some
level not entirely possible when using AI heavily (even coding involves small
judgments), but the core idea I think is sound and actually aligns with Howard's
point: only use AI where the problem is suitable for interpolation. The
precise level at which you can do this may vary a lot by domain - agents can
build a TODO app end-to-end, but in my experience they cannot design anything
but the most trivial graph algorithms effectively without guidance.

## Specification is the bottleneck

There's a lot of talk these days about how verification is the bottleneck
in software now that agents can code. I disagree.

I think verication is certainly a major problem, but it's also ameniable
to engineering solutions - for example a theorem prover can make verification
perfect in some domains, and even just aggressive holdout testing can give
us a lot of confidence (StrongDM's "AI factory" relies on this heavily, as
I understand it).

I think the real problem is specification, for three reasons:
- First, specification to some extent encompasses the *design* of
  software. I lean into Daniel Jackson's thinking here, and how he views
  the exploration of *concepts* to be a semiformal (or formal!) way
  of exploring design. To me, design is the most important thing both
  for making *useful* software and because it aligns better than other
  forms of specification with the idea of creating *flexible* software
  that can evolve iteratively (which is needed in practice for most
  projects). And Jackson argues convincingly that the most expensive
  errors in software are typically design-level errors, where the concepts
  themselves don't map well to the problem.
- Second, downstream of design the main goal in software is to get
  a good *architecture* and *algorithm* - for this, I lean into a lot
  of Leslie Lamport's thinking about how the essence of software development
  is not inventing *code* but inventing *algorithms* (and data structures).
  And Lamport argues that to do this well, it's better to find ways of thinking
  "above" the level of code because code often involves a large number of
  unimportant detals that can both slow down our thinking process and start
  to overshadow the core of the architecture and algorithm.
- Third, it seems very clear that the clarity and precision of specification
  has a huge impact on the scale of code that AI can write autonomously. It's
  unclear to me how soon codign becomes "a solved problem" but I actually
  can imagine that for many problems a highly detailed specification in
  some structured language - maybe a formal language, but not a code-level
  language - is sufficient to auto-generate most software. But it also
  seems very clear to me that for complex problems, at least as of
  April 2026 an English-language specification is very rarely precise
  enough (and also it's very rarely actually correct - it is *incredibly*
  difficult to write an English language doc and even figure out if it
  is even internally coherent).
- Fourth, verification cannot *possibly* be a solved problem for a given
  bit of software to any greater degree than specification is, because
  what would we be verifying? The extreme case is theorem provers, where
  specification is very precise (and difficult) and verification is
  potentially perfect, but even with other approaches a spec is clearly
  needed.

So to me, a lot of AI work should focus on exploring how can we be
good at specification? And with the above note about the human driver
as part of our context, this means trying to make specification:
- interactive, with relatively quick feedback
- a process that produces an artifact we can actually manage

We want to find ways to do this well - I think this was more important
than we often gave it credit for even before AI, but I think AI changes
the calculus, both making it more important and potentially giving
us new approaches that make it *easier* to focus on specification as
the core skill our discipline.
