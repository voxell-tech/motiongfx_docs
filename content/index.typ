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
// the theme toggle the way the rest of the page's CSS does. Instead,
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
  #html.a(
    class: "inline-block mb-4 px-3 py-1 rounded-full border border-text/15 text-muted text-sm hover:border-accent/50 hover:text-accent transition-colors",
    href: "#moxie",
  )[✨ New: Moxie, a visual editor for MotionGfx ↓]
  #html.h1(class: "text-6xl sm:text-7xl font-bold mb-4 tracking-tight")[
    Motion#html.span(class: "text-accent")[Gfx]
  ]

  #html.p(class: "text-muted text-xl mb-2 max-w-2xl mx-auto")[
    A *backend agnostic* motion graphics creation framework.
  ]
  #html.p(class: "text-muted text-lg mb-8 max-w-2xl mx-auto")[
    Free and open-source forever!
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
  description: "An action's closure receives the field's current value, so each step picks up wherever the last one left off.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: ui.rust-snippet("/js_motiongfx/src/demos/relative.rs"),
  preview: ui.player-block(
    id: "relative-demo",
    script: "/js/demos/relative-demo.js",
    caption: [Each step starts where the last one stopped.],
  ),
)

// Feature: it's just code
#ui.showcase-demo(
  title: "It's Just Code",
  description: "A scene is plain Rust, built with the same loops and variables you already use.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: ui.rust-snippet("/js_motiongfx/src/demos/bars.rs"),
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
  description: "A timeline bakes once. After that it plays at any speed, in either direction, or jumps straight to any frame without re-simulating anything.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: ui.rust-snippet("/js_motiongfx/src/demos/bounce.rs"),
  preview: ui.player-block(
    id: "bounce-demo",
    script: "/js/demos/bounce-demo.js",
    caption: [Drag the scrubber: backward costs the same as forward.],
  ),
)

// Feature: backend agnostic
#html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "flex flex-col md:flex-row items-center gap-8")[
    #html.div(class: "flex-1 text-center md:text-left")[
      #html.h2(class: "text-3xl font-bold mb-2")[Backend Agnostic]
      #html.p(class: "text-muted text-lg")[
        MotionGfx describes what changes and leaves drawing to the
        backend. Bevy is supported today, and any renderer that can read
        and write its own values can be next.
      ]
      #html.a(
        class: "inline-block mt-4 px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold hover:border-accent/50 hover:text-accent transition-colors",
        href: "/docs/advanced",
      )[Build Your Own Backend →]
    ]
    #html.div(class: "flex-1 flex justify-center")[
      #html.elem("div", attrs: (
        role: "img",
        aria-label: "Diagram: MotionGfx connects to Bevy today, with your own renderer or others pluggable in the same way.",
      ))[
        #html.span(class: "diagram-dark")[#html.frame(backend-diagram(dark: true))]
        #html.span(class: "diagram-light")[#html.frame(backend-diagram(dark: false))]
      ]
    ]
  ]
]

#layout.hr

// Feature: batteries included
#html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "flex flex-col md:flex-row-reverse items-center gap-8")[
    #html.div(class: "flex-1 text-center md:text-left")[
      #html.h2(class: "text-3xl font-bold mb-2")[Start With Bevy]
      #html.p(class: "text-muted text-lg")[
        Bevy MotionGfx handles the setup for you. Add the plugin, describe
        what should change, and it plays.
      ]
      #html.a(
        class: "inline-block mt-4 px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity",
        href: "/docs/bevy",
      )[Set Up Bevy MotionGfx →]
    ]
    #html.div(class: "flex-1 flex justify-center")[
      #html.elem("img", attrs: (
        src: "/icons/bevy.svg",
        alt: "Bevy",
        style: "height: 120px; width: auto;",
      ))
    ]
  ]
]

#layout.hr

// Feature: visual editor
// Full-width below the text, not squeezed into a half-width column
// beside it like the other feature sections: the screenshot's own UI
// labels need real width to read at all.
#html.section(id: "moxie", class: "py-12 px-4 sm:px-6")[
  #html.div(class: "text-center max-w-2xl mx-auto mb-8")[
    #html.h2(class: "text-3xl font-bold mb-2")[Prefer a Timeline You Can See?]
    #html.p(class: "text-muted text-lg")[
      #html.a(
        class: "font-semibold hover:text-accent transition-colors",
        href: "https://github.com/voxell-tech/moxie",
        target: "_blank",
        rel: ("noopener", "noreferrer"),
      )[Moxie]
      is a Bevy editor for MotionGfx: hierarchy, inspector, and a
      scrubbable timeline built on the same chain/all/flow combinators
      these docs cover, no code required to arrange them.
    ]
    #html.a(
      class: "inline-block mt-4 px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold hover:border-accent/50 hover:text-accent transition-colors",
      href: "https://github.com/voxell-tech/moxie",
      target: "_blank",
      rel: ("noopener", "noreferrer"),
    )[Check Out Moxie ↗]
  ]
  #html.div[
    #html.elem("img", attrs: (
      src: "/images/moxie-screenshot.webp",
      alt: "Moxie, a Bevy editor for MotionGfx, showing its hierarchy, viewport, inspector, and timeline panels",
      class: "rounded-lg",
      style: "width: 100%; height: auto;",
    ))
  ]
]

#layout.hr

// Newsletter: right after Moxie, since the list covers both projects.
#ui.newsletter()

#layout.hr

// Closing CTA
#html.div(class: "text-center py-12")[
  #html.h2(class: "text-3xl font-bold mb-4")[Ready to Animate?]
  #html.a(
    class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold text-lg hover:opacity-90 transition-opacity",
    href: "/docs",
  )[Get Started →]
]
