#import "/templates/page.typ": page
#import "/components/ui.typ" as ui
#import "/components/layout.typ" as layout

#show: page.with(title: none)

// Hero
#html.div(class: "text-center py-20 px-5")[
  #html.h1(class: "text-6xl sm:text-7xl font-bold mb-4 tracking-tight")[
    Motion#html.span(class: "text-accent")[Gfx]
  ]

  #html.p(class: "text-muted text-xl mb-8 max-w-2xl mx-auto")[
    A *backend-agnostic* motion graphics framework for *procedural* animation.
  ]

  #html.div(class: "flex flex-wrap justify-center gap-3")[
    #html.a(
      class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold text-lg hover:opacity-90 transition-opacity",
      href: "/docs",
    )[Get Started]
    #html.a(
      class: "px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold text-lg hover:border-accent/50 hover:text-accent transition-colors",
      href: "https://github.com/voxell-tech/motiongfx",
      target: "_blank",
      rel: ("noopener", "noreferrer"),
    )[View on GitHub ↗]
  ]
]

#layout.hr

// Feature: procedural, type-erased animation
#ui.showcase-demo(
  title: "Procedural, Not Keyframed",
  description: "Describe how a value changes and let the timeline compile it. No hand-placed keyframes to keep in sync.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: [
    ```rust
    // subject, field, and its new value
    let grow = b.act(RADIUS, path!(<f32>), |_| 70.0)
        .with_ease(ease::cubic::ease_in_out)
        .play(s(1));

    let track = grow.compile();
    ```
  ],
  preview: html.elem("div", attrs: (
    class: "flex flex-col items-center justify-center gap-3 h-full min-h-32",
    // Not a `<script>` tag: see assets/js/demo-bootstrap.js for why an
    // inserted script never runs after Tola's SPA navigation, and why
    // this data attribute is what actually loads the demo instead.
    data-demo-src: "/js/demos/landing.js",
  ))[
    #html.elem("canvas", attrs: (
      id: "landing-demo",
      width: "160",
      height: "160",
      style: "width: 160px; height: 160px;",
    ))[]
    #html.p(class: "text-subtle text-sm")[Running live, in this page, right now.]
  ],
)

// Feature: batteries included
#html.section(class: "py-12")[
  #html.h2(class: "text-3xl font-bold mb-2 text-center")[Start With Bevy]
  #html.p(class: "text-muted text-center max-w-xl mx-auto text-lg")[
    Bevy MotionGfx wires everything up for you: add the plugin, describe
    what should change, and it plays. No boilerplate to write.
  ]
  #html.p(class: "text-subtle text-center max-w-xl mx-auto mt-3")[
    Using a different engine, or your own renderer? See
    #html.a(href: "/docs/advanced")[Building a Backend] to plug it in.
  ]
]

#layout.hr

// Feature: two-way playback
#html.section(class: "py-12")[
  #html.h2(class: "text-3xl font-bold mb-2 text-center")[Scrub Forward and Backward, for Free]
  #html.p(class: "text-muted text-center max-w-xl mx-auto text-lg")[
    Every timeline bakes once, then plays at any speed, in either direction,
    or jumps straight to a frame. No extra computation, no re-simulation.
  ]
]

#layout.hr

// Closing CTA
#html.div(class: "text-center py-12")[
  #html.h2(class: "text-3xl font-bold mb-4")[Ready to animate?]
  #html.a(
    class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold text-lg hover:opacity-90 transition-opacity",
    href: "/docs",
  )[Read the Quickstart →]
]
