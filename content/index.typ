#import "/templates/page.typ": page
#import "/components/ui.typ" as ui
#import "/components/layout.typ" as layout
#import "@preview/cetz:0.5.2": canvas, draw

#show: page.with(title: none)

// "Backend Agnostic" diagram: a real node/edge graph via CeTZ, embedded
// as an SVG via html.frame the same way templates/tola.typ embeds math.
// MotionGfx is the one core; backends are interchangeable pieces that
// snap onto it, like picking a Lego brick, not a fixed pipeline: Bevy's
// the one that exists today (solid line), the others are dashed:
// pluggable, not built yet.
//
// Colors bake into the SVG at build time, so this can't react live to
// the theme toggle the way the rest of the page's CSS does — instead,
// both variants get rendered up front (reusing this site's own light/
// dark tokens from shared/styles.css) and toggled with the same
// [data-theme] CSS technique the shared nav's sun/moon icon already
// uses (see .diagram-dark/.diagram-light in tailwind.css).
#let backend-diagram(dark: true) = {
  let accent = if dark { rgb("#78dce8") } else { rgb("#0d7a8a") }
  let accent-fill = if dark { rgb("#78dce826") } else { rgb("#0d7a8a1a") }
  let muted = if dark { rgb("#939293") } else { rgb("#727072") }
  let dim = if dark { rgb("#5b5a5c") } else { rgb("#b5b3b5") }
  let muted-text = if dark { rgb("#fcfcfa") } else { rgb("#2d2a2e") }

  box(inset: 20pt)[
    #canvas(length: 1cm, {
      import draw: *

      let piece(label, dashed: false) = box(
        radius: 8pt,
        stroke: (
          paint: if dashed { dim } else { muted },
          thickness: 1.5pt,
          dash: if dashed { "dashed" } else { none },
        ),
        inset: (x: 12pt, y: 8pt),
      )[#text(fill: muted-text, size: 10pt)[#label]]

      content((0.0, 0.0), name: "core")[
        #box(
          radius: 8pt,
          fill: accent-fill,
          stroke: 1.5pt + accent,
          inset: (x: 14pt, y: 8pt),
        )[#text(fill: accent, weight: "bold", size: 13pt)[MotionGfx]]
      ]
      content((-3.0, -2.2), name: "bevy")[#piece("Bevy")]
      content((0.0, -2.2), name: "custom")[#piece("Your Renderer", dashed: true)]
      content((3.0, -2.2), name: "more")[#piece("...", dashed: true)]

      line("core.south", "bevy.north", stroke: 1.5pt + accent, mark: (
        end: ">",
        fill: accent,
      ))
      line(
        "core.south",
        "custom.north",
        stroke: (paint: dim, thickness: 1.5pt, dash: "dashed"),
        mark: (end: ">", fill: dim),
      )
      line(
        "core.south",
        "more.north",
        stroke: (paint: dim, thickness: 1.5pt, dash: "dashed"),
        mark: (end: ">", fill: dim),
      )
    })
  ]
}

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
      class: "flex items-center gap-2 px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold text-lg hover:border-accent/50 hover:text-accent transition-colors",
      href: "https://github.com/voxell-tech/motiongfx",
      target: "_blank",
      rel: ("noopener", "noreferrer"),
    )[
      #html.elem("span", attrs: (
        class: "social-icon",
        style: "--icon: url('/icons/github.svg'); background-color: currentColor;",
      ))
      View on GitHub ↗
    ]
  ]
]

#layout.hr

// Feature: relative actions
#ui.showcase-demo(
  title: "Relative, Not Absolute",
  description: "An action's closure receives the field's current value, so each step can build on wherever the last one left off, not jump to a fixed number pulled from nowhere.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: [
    ```rust
    let deltas = [Vec2::new(180.0, 50.0), Vec2::new(180.0, -100.0), Vec2::new(180.0, 50.0)];
    let tracks = deltas.map(|delta| b.act(dot, path!(<Circle>::position), |p| p + delta)
        .play(cs(50)));

    tracks.ord_chain()
    ```
  ],
  preview: ui.player-block(
    id: "relative-demo",
    script: "/js/demos/relative-demo.js",
    caption: [Each step starts where the last one stopped.],
  ),
)

// Feature: it's just code
#ui.showcase-demo(
  title: "It's Just Code",
  description: "No special timeline UI to hand-place anything in: a scene is built with the same loops and variables you already reach for.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: [
    ```rust
    let stagger = cs(6);
    let tracks = bars.iter()
        .zip(heights)
        .map(|(bar, height)| b.act(*bar, path!(<Bar>::height), |_| height)
            .play(s(0.6)))
        .collect::<Vec<_>>();

    tracks.ord_flow(stagger)
    ```
  ],
  preview: ui.player-block(
    id: "loop-demo",
    script: "/js/demos/loop-demo.js",
    caption: [Ten bars, one `.map()`, one shared variable.],
  ),
  reverse: true,
)

// Feature: two-way playback
#ui.showcase-demo(
  title: "Scrub Forward and Backward, for Free",
  description: "Every timeline bakes once, then plays at any speed, in either direction, or jumps straight to a frame. No extra computation, no re-simulation.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: [
    ```rust
    // Any time, any order: forward, backward, twice at once.
    timeline.set_target_time(cs(50));
    timeline.queue_actions();
    timeline.sample_queued_actions(&registry, &mut world);
    ```
  ],
  preview: ui.player-block(
    id: "bounce-demo",
    script: "/js/demos/bounce-demo.js",
    caption: [Drag the scrubber, backward costs the same as forward.],
  ),
)

// Feature: backend agnostic
#html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "flex flex-col md:flex-row-reverse items-center gap-8")[
    #html.div(class: "flex-1 flex justify-center")[
      #html.span(class: "diagram-dark")[#html.frame(backend-diagram(dark: true))]
      #html.span(class: "diagram-light")[#html.frame(backend-diagram(dark: false))]
    ]
    #html.div(class: "flex-1 text-center md:text-left")[
      #html.h2(class: "text-3xl font-bold mb-2")[Backend Agnostic]
      #html.p(class: "text-muted text-lg")[
        MotionGfx describes what changes, never how it gets drawn. Any
        renderer that can read a value back can play it: Bevy today,
        anything else tomorrow.
      ]
      #html.a(
        class: "inline-block mt-4 px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold hover:border-accent/50 hover:text-accent transition-colors",
        href: "/docs/advanced",
      )[Build Your Own Backend →]
    ]
  ]
]

#layout.hr

// Feature: batteries included
#html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "flex flex-col md:flex-row items-center gap-8")[
    #html.div(class: "flex-1 flex justify-center")[
      #html.elem("img", attrs: (
        src: "/icons/bevy.svg",
        alt: "Bevy",
        style: "height: 120px; width: auto;",
      ))
    ]
    #html.div(class: "flex-1 text-center md:text-left")[
      #html.h2(class: "text-3xl font-bold mb-2")[Start With Bevy]
      #html.p(class: "text-muted text-lg")[
        Bevy MotionGfx wires everything up for you: add the plugin, describe
        what should change, and it plays. No boilerplate to write.
      ]
      #html.a(
        class: "inline-block mt-4 px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity",
        href: "/docs/bevy",
      )[Set Up Bevy MotionGfx →]
    ]
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
