# Specification Tools

Following my philosophy for agents, a big priority to me is to find ways of
doing software specification where I can remain in flow and deeply immersed in
a problem, understanding the structure of the solution and getting good
feedback similar to what I could get with a testing loop and coding.

This doc describes some approaches I've tried, and some approaches I'd like
to explore further.

## Design Specification

To me, at the moment it seems like Alloy Analyzer is probably the best
design specification tool; it's relational-first model is aligned with
its creator Daniel Jackson's view of software as centered around concepts.

I've explored this a bit with agents, and my opinion is that agents have
no problem writing Alloy; they've typically seen less of it than TLA+ in
training, but it's a fairly simple tool (used to model complex things).

I'm still exploring ideas about how to actually do design, but my starting
point has been Jackson's *The Essence of Software*, which explores
concept-oriented design in detail and is also a great jumping-off point for a
lot of other literature on design, product, and software engineering.

I'm hoping to have more thoughts on this in the future.

## Algorithm Specification with Modeling Languages

The Alloy Analyzer tool is - especially with temporal operators in Alloy 6 -
certainly an option for specifying some kinds of algorithms.

But I think that there are some major scalablity issues that can get in
the way with Alloy. I had very good luck, on the other hand, specifying some
graph algorithms in Pyrefly with TLA+. Agents were *very* good with TLA+,
which is really cool because learning to read TLA+ is not actually that hard
but learning to write it is trickier. This was actually one of the best
pair-programming experiences I've had with agents to date - it felt like
both myself and the agents were far better to hold the problem as a whole
in context and collaborate than is the case with code.

I'm very interested in also exploring new tools in this space:
- Quint is the most promising. It's sort of an extension of TLA+ (it can
  compile to TLA+) but is designed to make different tradeoffs, treating
  a spec more like software and less like math: it uses a more code-like
  syntax, but more importantly it has a type system. In addition, it's
  designed to emphasize fast simulation and not just model checking, so
  - It has some of the upside of Alloy (which makes simulating and looking
    at examples easier than TLA+ does)
  - It also might scale well to very large specifications and examples,
    where model checking is very slow but simulation can still be fast.
- FizzBee is also interesting; in principle I think it's designed to have
  more capabilities than Quint (e.g. visualization of components,
  probabilistic simulation) but I'm not convinced it is or will be as
  mature a tool.

With all of these tools, the ability of agents to help co-work on the
spec is quite valuable. In addition, agents are *great* at building
throwaway logic to help explore the results: you can write scripts
to summarize results, build custom visualizations, and do all sorts
of other things that would have been too annoying before.

## Whiteboard Specification

There are some problems that I think are friendly to formal modeling
as in TLA+ or alloy. Very high-level designs might be, the relational
modeling of Alloy expecially can be useful. And something like a graph
algorithm is very well suited to mathematical-style specification.

In particular, I work on a type checker and in practice I think it's
pretty hard to formally specify any small change unless we have a
specification of everything else (which would be an enormous effort).

But I recently tried specifying a tricky type system change with an
agent in a way motivated by how I might have worked with a coworker:
I fed a few examples to an AI and co-designed an initial sketch of
an algorithm to it. Then, we expanded to a larger set of examples trying
to explore edge cases and composablity issues, and I had it fan out
subagents to work through the examples by hand highlighting anywhere
that the design was either wrong or just lacked important details that
might not be obvious to an implementation agent.

This process actually helped me address a *lot* of problems that I
don't think I could have caught until implementation otherwise, and honestly
even after that (at which point the design was basically correct) getting
the implementation right was still very hard. If I had needed to fix both
design and implementation issues together, I think the project might have
failed.

In general this convinced me that the agent itself can potentially act
a little like a formal modeling tool, when the problem is too vague for
actual formal modeling: agents aren't bad at step-by-step tracing of an
algorithm, but unlike a formal tool they can handle a bit of vagueness
which is useful both because a *little* imprecision is probably okay
and because they can suggest improvements when we need more precision.

I hope to use this approach much more often going forward.
