#import "/templates/docs.typ": docs-page
#import "/components/ui.typ" as ui

#show: docs-page.with(title: "Ordering")

= Ordering

`.play(duration)` only times one action. To combine several, wrap them in
one of these five combinators before calling `.compile()`.

== chain

Run fragments one after another.

```rust
[frag_a.play(s(1)), frag_b.play(s(1))].ord_chain()
```

`frag_b` starts the moment `frag_a` finishes.

#ui.live-demo-with-diagram(
  id: "ordering-chain-demo",
  script: "/js/demos/ordering-chain.js",
  caption: [The second circle waits for the first.],
  diagram: ui.group(label: "chain")[
    #ui.track-row(total: 2.0, blocks: (
      (label: "a", color: "#78dce8", start: 0.0, end: 1.0),
      (label: "b", color: "#ab9df2", start: 1.0, end: 2.0),
    ))
  ],
)

== all

Run fragments together. Finishes when the slowest one does.

```rust
chain([
  [frag_a.play(s(1)), frag_b.play(cs(50))].ord_all(),
  frag_c.play(cs(50)),
])
```

The square waits for the slower circle before it starts.

#ui.live-demo-with-diagram(
  id: "ordering-all-demo",
  script: "/js/demos/ordering-all.js",
  caption: [The square starts once both circles have arrived.],
  diagram: ui.group(label: "chain")[
    #ui.group(label: "all")[
      #ui.track-row(total: 1.5, blocks: (
        (label: "a", color: "#78dce8", start: 0.0, end: 1.0),
      ))
      #ui.track-row(total: 1.5, blocks: (
        (label: "b", color: "#ab9df2", start: 0.0, end: 0.5),
      ))
    ]
    #ui.track-row(total: 1.5, blocks: (
      (label: "c", color: "#ffd866", start: 1.0, end: 1.5),
    ))
  ],
)

== any

Run fragments together. Finishes as soon as the fastest one does.

```rust
chain([
  [frag_a.play(s(1)), frag_b.play(cs(50))].ord_any(),
  frag_c.play(cs(50)),
])
```

The square starts as soon as the faster circle arrives, compare that to
`all` above.

#ui.live-demo-with-diagram(
  id: "ordering-any-demo",
  script: "/js/demos/ordering-any.js",
  caption: [The square starts the moment the faster circle arrives.],
  diagram: ui.group(label: "chain")[
    #ui.group(label: "any")[
      #ui.track-row(total: 1.0, blocks: (
        (label: "a", color: "#78dce8", start: 0.0, end: 0.5, full-end: 1.0),
      ))
      #ui.track-row(total: 1.0, blocks: (
        (label: "b", color: "#ab9df2", start: 0.0, end: 0.5),
      ))
    ]
    #ui.track-row(total: 1.0, blocks: (
      (label: "c", color: "#ffd866", start: 0.5, end: 1.0),
    ))
  ],
)

== flow

Like `chain`, but each fragment starts a fixed delay after the previous one
starts, not after it finishes.

```rust
circles.iter().map(|c| c.play(cs(60))).ord_flow(cs(15))
```

#ui.live-demo-with-diagram(
  id: "ordering-flow-demo",
  script: "/js/demos/ordering-flow.js",
  caption: [A wave ripples through the row: each circle starts shortly after the last, not after it finishes.],
  diagram: ui.group(label: "flow")[
    #ui.track-row(total: 1.2, blocks: (
      (label: "c0", color: "#78dce8", start: 0.0, end: 0.6),
    ))
    #ui.track-row(total: 1.2, blocks: (
      (label: "c1", color: "#78dce8", start: 0.15, end: 0.75),
    ))
    #ui.track-row(total: 1.2, blocks: (
      (label: "c2", color: "#78dce8", start: 0.3, end: 0.9),
    ))
    #ui.track-row(total: 1.2, blocks: (
      (label: "c3", color: "#78dce8", start: 0.45, end: 1.05),
    ))
    #ui.track-row(total: 1.2, blocks: (
      (label: "c4", color: "#78dce8", start: 0.6, end: 1.2),
    ))
  ],
)

== delay

Push a single fragment's start later.

```rust
use motiongfx::track::delay;

delay(cs(30), frag_a.play(s(1)))
```

#ui.live-demo-with-diagram(
  id: "ordering-delay-demo",
  script: "/js/demos/ordering-delay.js",
  caption: [The circle sits still, then starts moving.],
  diagram: ui.group(label: "delay")[
    #ui.track-row(total: 1.3, blocks: (
      (label: "a", color: "#78dce8", start: 0.3, end: 1.3),
    ))
  ],
)
