#import "@tola/source:0.0.0": tola-meta
#import "/components/ordering.typ" as ordering

#tola-meta((
  title: "Ordering",
  summary: "Combine animation fragments with chain, all, any, flow, and delay, with a live demo of each.",
  layout: "docs",
))

= Ordering

`.play(duration)` turns one action into a fragment. To combine several
fragments, order them with one of these five combinators before calling
`.compile()`. In the snippets below, `a`, `b`, and `c` are actions, not
the builder.

== Chain

Run fragments one after another.

#ordering.code("chain")

`b` starts the moment `a` finishes.

#ordering.demo("chain")

== All

Run fragments together. Finishes when the slowest one does.

#ordering.code("all")

The square waits for the slower circle before it starts.

#ordering.demo("all")

== Any

Run fragments together. Finishes as soon as the fastest one does.

#ordering.code("any")

The square starts as soon as the faster circle arrives. Compare that to
`all` above.

#ordering.demo("any")

== Flow

Like `chain`, except each fragment starts a fixed delay after the previous
one starts, instead of waiting for it to finish.

#ordering.code("flow")

#ordering.demo("flow")

== Delay

Push a single fragment's start later.

#ordering.code("delay")

#ordering.demo("delay")
