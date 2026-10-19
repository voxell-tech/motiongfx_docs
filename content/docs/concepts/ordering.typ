#import "@tola/source:0.0.0": tola-meta
#import "/components/player.typ" as player

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

```rust
[a.play(s(1)), b.play(s(1))].ord_chain()
```

`b` starts the moment `a` finishes.

#player.live-demo-with-diagram(
  id: "ordering-chain-demo",
  script: "/js/demos/ordering-chain.js",
  caption: [The second circle waits for the first.],
  diagram: player.group(label: "chain")[
    #player.track-row(total: 2.0, blocks: (
      (label: "a", color: "#78dce8", start: 0.0, end: 1.0),
      (label: "b", color: "#ab9df2", start: 1.0, end: 2.0),
    ))
  ],
)

== All

Run fragments together. Finishes when the slowest one does.

```rust
[
    [a.play(s(1)), b.play(cs(50))].ord_all(),
    c.play(cs(50)),
]
.ord_chain()
```

The square waits for the slower circle before it starts.

#player.live-demo-with-diagram(
  id: "ordering-all-demo",
  script: "/js/demos/ordering-all.js",
  caption: [The square starts once both circles have arrived.],
  diagram: player.group(label: "chain")[
    #player.group(label: "all")[
      #player.track-row(total: 1.5, blocks: (
        (label: "a", color: "#78dce8", start: 0.0, end: 1.0),
      ))
      #player.track-row(total: 1.5, blocks: (
        (label: "b", color: "#ab9df2", start: 0.0, end: 0.5),
      ))
    ]
    #player.track-row(total: 1.5, blocks: (
      (label: "c", color: "#ffd866", start: 1.0, end: 1.5),
    ))
  ],
)

== Any

Run fragments together. Finishes as soon as the fastest one does.

```rust
[
    [a.play(s(1)), b.play(cs(50))].ord_any(),
    c.play(cs(50)),
]
.ord_chain()
```

The square starts as soon as the faster circle arrives. Compare that to
`all` above.

#player.live-demo-with-diagram(
  id: "ordering-any-demo",
  script: "/js/demos/ordering-any.js",
  caption: [The square starts the moment the faster circle arrives.],
  diagram: player.group(label: "chain")[
    #player.group(label: "any")[
      #player.track-row(total: 1.0, blocks: (
        (label: "a", color: "#78dce8", start: 0.0, end: 0.5, full-end: 1.0),
      ))
      #player.track-row(total: 1.0, blocks: (
        (label: "b", color: "#ab9df2", start: 0.0, end: 0.5),
      ))
    ]
    #player.track-row(total: 1.0, blocks: (
      (label: "c", color: "#ffd866", start: 0.5, end: 1.0),
    ))
  ],
)

== Flow

Like `chain`, except each fragment starts a fixed delay after the previous
one starts, instead of waiting for it to finish.

```rust
actions.map(|a| a.play(cs(60))).ord_flow(cs(15))
```

#player.live-demo-with-diagram(
  id: "ordering-flow-demo",
  script: "/js/demos/ordering-flow.js",
  caption: [A wave ripples through the row: each circle starts shortly after the last, not after it finishes.],
  diagram: player.group(label: "flow")[
    #player.track-row(total: 1.2, blocks: (
      (label: "c0", color: "#78dce8", start: 0.0, end: 0.6),
    ))
    #player.track-row(total: 1.2, blocks: (
      (label: "c1", color: "#78dce8", start: 0.15, end: 0.75),
    ))
    #player.track-row(total: 1.2, blocks: (
      (label: "c2", color: "#78dce8", start: 0.3, end: 0.9),
    ))
    #player.track-row(total: 1.2, blocks: (
      (label: "c3", color: "#78dce8", start: 0.45, end: 1.05),
    ))
    #player.track-row(total: 1.2, blocks: (
      (label: "c4", color: "#78dce8", start: 0.6, end: 1.2),
    ))
  ],
)

== Delay

Push a single fragment's start later.

```rust
use motiongfx::track::delay;

delay(cs(30), a.play(s(1)))
```

#player.live-demo-with-diagram(
  id: "ordering-delay-demo",
  script: "/js/demos/ordering-delay.js",
  caption: [The circle sits still, then starts moving.],
  diagram: player.group(label: "delay")[
    #player.track-row(total: 1.3, blocks: (
      (label: "a", color: "#78dce8", start: 0.3, end: 1.3),
    ))
  ],
)
