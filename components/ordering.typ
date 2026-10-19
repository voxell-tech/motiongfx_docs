// The five ordering combinators, each with its snippet, live demo, and
// timing diagram. The Ordering docs page walks through them one by one;
// the landing page shows them as tabs.
// Import: #import "/components/ordering.typ" as ordering

#import "/components/player.typ" as player

#let combinators = (
  chain: (
    code: ```rust
    [a.play(s(1)), b.play(s(1))].ord_chain()
    ```,
    id: "ordering-chain-demo",
    script: "/js/demos/ordering-chain.js",
    caption: [The second circle waits for the first.],
    diagram: player.group(label: "chain")[
      #player.track-row(total: 2.0, blocks: (
        (label: "a", color: "#78dce8", start: 0.0, end: 1.0),
        (label: "b", color: "#ab9df2", start: 1.0, end: 2.0),
      ))
    ],
  ),
  all: (
    code: ```rust
    [
        [a.play(s(1)), b.play(cs(50))].ord_all(),
        c.play(cs(50)),
    ]
    .ord_chain()
    ```,
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
  ),
  any: (
    code: ```rust
    [
        [a.play(s(1)), b.play(cs(50))].ord_any(),
        c.play(cs(50)),
    ]
    .ord_chain()
    ```,
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
  ),
  flow: (
    code: ```rust
    actions.map(|a| a.play(cs(60))).ord_flow(cs(15))
    ```,
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
  ),
  delay: (
    code: ```rust
    use motiongfx::track::delay;

    delay(cs(30), a.play(s(1)))
    ```,
    id: "ordering-delay-demo",
    script: "/js/demos/ordering-delay.js",
    caption: [The circle sits still, then starts moving.],
    diagram: player.group(label: "delay")[
      #player.track-row(total: 1.3, blocks: (
        (label: "a", color: "#78dce8", start: 0.3, end: 1.3),
      ))
    ],
  ),
)

/// `name`'s snippet.
#let code(name) = combinators.at(name).code

/// `name`'s live demo beside its timing diagram.
#let demo(name) = {
  let c = combinators.at(name)
  player.live-demo-with-diagram(
    id: c.id,
    script: c.script,
    caption: c.caption,
    diagram: c.diagram,
  )
}

/// Every combinator as a tab: the snippet, then the demo and diagram.
/// assets/js/ordering-tabs.js switches between them.
#let tabs = html.elem("div", attrs: (
  class: "ordering-tabs",
  data-demo-src: "/js/ordering-tabs.js",
))[
  #html.div(class: "ordering-tab-row", role: "tablist", {
    for (i, name) in combinators.keys().enumerate() {
      html.elem("button", attrs: (
        type: "button",
        class: "ordering-tab",
        role: "tab",
        data-tab: name,
        aria-selected: if i == 0 { "true" } else { "false" },
      ))[#raw(name)]
    }
  })
  #for (i, (name, c)) in combinators.pairs().enumerate() {
    html.elem("div", attrs: (
      class: "ordering-panel",
      role: "tabpanel",
      data-panel: name,
      ..if i != 0 { (hidden: "") },
    ))[
      #c.code
      #demo(name)
    ]
  }
]
