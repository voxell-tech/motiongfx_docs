#import "@tola/source:0.0.0": tola-meta
#import "/shared/site/ui.typ" as ui
#import "/components/player.typ" as player
#import "/project.typ": newsletter-form

#tola-meta((
  title: none,
  summary: "MotionGfx is a backend agnostic motion graphics creation framework for Rust. Free and open-source forever.",
))

#ui.hero(
  [Motion#html.span(class: "text-accent")[Gfx]],
  pill: ui.pill(
    "#moxie",
  )[✨ New: Moxie, a visual editor for MotionGfx ↓],
  tagline: [A *backend agnostic* motion graphics creation framework.],
  subtitle: [Free and open-source forever!],
  actions: (
    ui.button("/docs/", large: true)[Get Started],
    ui.github-button("https://github.com/voxell-tech/motiongfx"),
  ),
)

#ui.hr

// Feature: relative actions
#ui.showcase-demo(
  title: "Relative, Not Absolute",
  description: "An action's closure receives the field's current value, so each step picks up wherever the last one left off.",
  code-label: "Rust",
  preview-label: "Live Playground",
  code: ui.rust-snippet("/js_motiongfx/src/demos/relative.rs"),
  preview: player.player-block(
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
  preview: player.player-block(
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
  preview: player.player-block(
    id: "bounce-demo",
    script: "/js/demos/bounce-demo.js",
    caption: [Drag the scrubber: backward costs the same as forward.],
  ),
)

// Feature: backend agnostic. It also triggers the newsletter popup
// (shared/scripts/newsletter-popup.js): reaching it means the visitor
// has scrolled past all three demos.
#ui.feature(
  [Backend Agnostic],
  [
    MotionGfx describes what changes and leaves drawing to the
    backend. Bevy is supported today, and any renderer that can read
    and write its own values can be next.
  ],
  id: "backend-agnostic",
  attrs: (data-newsletter-trigger: ""),
  action: ui.feature-button(
    "/docs/advanced/",
  )[Build Your Own Backend →],
  media: ui.backend-diagram(
    "MotionGfx",
    (
      (label: "Bevy", ready: true),
      (label: "Your Renderer"),
      (label: "..."),
    ),
    label: "Diagram: MotionGfx connects to Bevy today, with your own renderer or others pluggable in the same way.",
  ),
)

#ui.hr

// Feature: batteries included
#ui.feature(
  [Start With Bevy],
  [
    Bevy MotionGfx handles the setup for you. Add the plugin, describe
    what should change, and it plays.
  ],
  reverse: true,
  action: ui.feature-button(
    "/docs/bevy/",
    primary: true,
  )[Set Up Bevy MotionGfx →],
  media: html.elem("img", attrs: (
    src: "/icons/bevy.svg",
    alt: "Bevy",
    style: "height: 120px; width: auto;",
  )),
)

#ui.hr

// Feature: visual editor
// Full-width below the text, not squeezed into a half-width column
// beside it like the other feature sections: the screenshot's own UI
// labels need real width to read at all.
#html.section(id: "moxie", class: "py-12 px-4 sm:px-6")[
  #ui.section-heading(
    [Prefer a Timeline You Can See?],
    [
      #html.a(
        class: "font-semibold hover:text-accent transition-colors",
        href: "https://github.com/voxell-tech/moxie",
        target: "_blank",
        rel: ("noopener", "noreferrer"),
      )[Moxie]
      is a Bevy editor for MotionGfx, with a hierarchy, an inspector, and
      a scrubbable timeline built on the same chain/all/flow combinators
      these docs cover. You arrange them visually, without writing code.
    ],
    action: ui.feature-button(
      "https://github.com/voxell-tech/moxie",
    )[Check Out Moxie ↗],
  )
  #html.div[
    #html.elem("img", attrs: (
      src: "/images/moxie-screenshot.webp",
      alt: "Moxie, a Bevy editor for MotionGfx, showing its hierarchy, viewport, inspector, and timeline panels",
      class: "rounded-lg",
      style: "width: 100%; height: auto;",
    ))
  ]
]

#ui.hr

// Newsletter: right after Moxie, since the list covers both projects.
#ui.newsletter(newsletter-form)[
  We'll email you when MotionGfx or Moxie has something new.
]
#ui.newsletter-popup(newsletter-form)[
  MotionGfx and Moxie news, now and then.
]

#ui.hr

// Closing CTA
#ui.cta(
  [Ready to Animate?],
  ui.button("/docs/", large: true)[Get Started →],
)
