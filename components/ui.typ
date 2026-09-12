// UI components
// Import: #import "/components/ui.typ" as ui

#import "/utils/tola.typ": cls
#import "/components/layout.typ" as layout

/// Navigation link
#let nav-link(href, label) = html.a(
  class: "text-muted hover:text-accent transition-colors",
  href: href,
)[#label]

/// Tag badge
#let tag(name) = html.span(
  class: "px-2 py-1 text-xs bg-surface rounded text-accent",
)[#name]

/// Card container
#let card(title: none, body) = html.div(class: "p-4 bg-surface rounded-lg")[
  #if title != none { html.h3(class: "font-semibold text-accent mb-2")[#title] }
  #body
]

/// Post card for blog listings
#let post-card(post) = {
  let date = post.at("date", default: "")
  html.a(
    class: "block mb-6 p-4 border border-text/10 rounded-lg bg-surface/50 hover:bg-surface transition-colors no-underline group",
    href: post.permalink,
  )[
    #html.h3(
      class: "text-xl font-semibold mb-2 group-hover:text-accent transition-colors",
    )[
      #post.title
    ]

    #layout.flex-row(
      gap: 4,
      html.span(class: "text-sm text-muted")[#date],
      ..post.at("tags", default: ()).map(t => tag(t)),
    )

    #if post.at("summary", default: none) != none {
      html.p(class: "mt-2 text-muted")[#post.at("summary")]
    }
  ]
}

/// Project card with name, shields.io badges, and description
#let project-card(name, url, repo, description, crate: none) = html.div(
  class: "flex flex-col p-4 bg-surface rounded-lg border border-text/10 hover:border-accent/30 transition-colors",
)[
  #html.a(
    class: "font-bold text-lg hover:text-accent transition-colors mb-2",
    href: url,
    target: "_blank",
    rel: ("noopener", "noreferrer"),
  )[#name ↗]
  #html.p(class: "text-muted text-sm mb-3 grow")[#description]
  #let c = if crate != none { crate } else { name }
  #let crates-url = "https://crates.io/crates/" + c
  #html.div(class: "flex flex-wrap mt-auto")[
    #html.a(href: url, target: "_blank", rel: ("noopener", "noreferrer"))[
      #html.elem("img", attrs: (
        src: "https://img.shields.io/github/stars/"
          + repo
          + "?style=flat&logo=github&label",
        alt: "GitHub stars",
        height: "20",
      ))
    ]
    #html.a(href: crates-url, target: "_blank", rel: (
      "noopener",
      "noreferrer",
    ))[
      #html.elem("img", attrs: (
        src: "https://img.shields.io/crates/v/"
          + c
          + "?style=flat&logo=rust&label",
        alt: "crates.io version",
        height: "20",
      ))
    ]
  ]
]

/// Side-by-side showcase card: source code + rendered output.
#let showcase-demo(
  title: none,
  description: none,
  code: none,
  preview: none,
  code-label: "Typst Code",
  preview-label: "Rendered Output",
) = {
  assert(title != none, message: "showcase-demo: `title` is required")
  assert(code != none, message: "showcase-demo: `code` is required")
  assert(preview != none, message: "showcase-demo: `preview` is required")

  html.section(
    class: "my-8 rounded-lg border border-text/10 bg-gradient-to-br from-bg/80 via-bg/50 to-surface/20 p-4 sm:p-6",
  )[
    #html.div(class: "mb-4")[
      #html.h3(class: "text-lg sm:text-xl font-semibold text-accent")[
        #title
      ]
      #if description != none {
        html.p(class: "mt-1 text-sm text-subtle")[
          #description
        ]
      }
    ]

    #html.div(class: "grid gap-4")[
      #html.div(
        class: "rounded-lg border border-text/10 bg-bg/70 overflow-hidden",
      )[
        #html.div(
          class: "border-b border-text/10 px-3 py-2 text-xs uppercase tracking-wide text-muted",
        )[
          #code-label
        ]
        #html.div(class: "p-3 text-sm")[
          #code
        ]
      ]

      #html.div(
        class: "rounded-lg border border-accent/30 bg-surface/40 overflow-hidden",
      )[
        #html.div(
          class: "border-b border-accent/20 px-3 py-2 text-xs uppercase tracking-wide text-accent",
        )[
          #preview-label
        ]
        #html.div(class: "p-3 text-sm")[
          #preview
        ]
      ]
    ]
  ]
}

/// The player itself: canvas + shell, no outer margin. Shared by
/// `live-demo` (standalone) and `live-demo-with-diagram` (beside a
/// `track-diagram`), so the margin isn't applied twice in the combined
/// layout.
///
/// `script` isn't emitted as a `<script>` tag: on Tola's SPA
/// navigation, an inserted `<script>` never executes (that's a DOM
/// morph, not a real parse), so a demo whose only page wasn't the one
/// you hard-loaded would never run. Instead the shell carries `script`
/// as `data-demo-src`, and assets/js/demo-bootstrap.js (loaded once,
/// present on every page) dynamically `import()`s it, which works
/// regardless of how the calling markup was inserted.
#let player-block(id: none, script: none, width: 680, height: 170, caption: none) = {
  assert(id != none, message: "live-demo: `id` is required")
  assert(script != none, message: "live-demo: `script` is required")

  html.div(class: "flex flex-col items-center gap-2")[
    #html.elem("div", attrs: (
      class: "mgfx-player-shell",
      style: "width: 100%;",
      data-demo-src: script,
    ))[
      #html.elem("canvas", attrs: (
        id: id,
        class: "mgfx-player-canvas",
        width: str(width),
        height: str(height),
        style: "aspect-ratio: " + str(width) + " / " + str(height) + ";",
      ))[]
    ]
    #if caption != none {
      html.p(class: "text-subtle text-xs")[#caption]
    }
  ]
}

/// A live canvas demo, mounted by the module at `script`. `id` must be
/// unique on the page; the script mounts by selecting `#id`. The canvas
/// sits in a `.mgfx-player-shell` (see tailwind.css) alongside the
/// play/pause + scrubber bar that mgfx-demo.js inserts right after it.
/// `width`/`height` set the canvas's logical coordinate space (what the
/// demo's own `x`/`y` positions are in) and its aspect ratio; the shell
/// itself always spans the full width of its container.
#let live-demo(id: none, script: none, width: 680, height: 170, caption: none) = {
  html.div(class: "my-4")[
    #player-block(id: id, script: script, width: width, height: height, caption: caption)
  ]
}

/// A small labeled box drawn around one level of a combinator's
/// nesting, e.g. `ui.group(label: "chain")[#ui.group(label: "all")[...]
/// #ui.track-row(...)]` for `chain([all([...]), frag_c])` — mirroring
/// the Rust code's own nesting, like the reference timeline's boxes.
#let group(label: none, body) = html.div(
  class: "border border-text/10 rounded-md p-1.5 flex flex-col gap-1",
)[
  #html.div(class: "text-[9px] text-subtle uppercase tracking-wide")[#label]
  #body
]

/// One row of blocks on a shared 0..`total`-second axis: the caller
/// decides which blocks share a row, since that's a property of the
/// combinator being illustrated (sequential blocks, like `chain`'s,
/// share a row; concurrent ones, like `all`'s, each need their own).
/// `blocks` is an array of dictionaries: `(label:, color:, start:,
/// end:)`, and optionally `full-end:` when a shape's own action runs
/// longer than the group lets it: a dashed outline spans the full
/// `start`..`full-end` (the action's real, authored length), with the
/// solid block layered on top spanning only `start`..`end` (where the
/// group actually cuts it off).
#let track-row(total: none, blocks: ()) = html.div(class: "relative h-7")[
  #for t in blocks {
    let pct(secs) = calc.min(secs, total) / total * 100
    let start-pct = pct(t.start)
    let end-pct = pct(t.end)
    let full-end = t.at("full-end", default: t.end)

    if full-end > t.end {
      html.div(
        class: "absolute inset-y-0 rounded border border-dashed opacity-60",
        style: "left: " + str(start-pct) + "%; width: " + str(pct(full-end) - start-pct) + "%; border-color: " + t.color + ";",
      )[]
    }
    html.div(
      class: "absolute inset-y-0 rounded flex items-center justify-center text-[10px] font-semibold overflow-hidden whitespace-nowrap",
      style: "left: " + str(start-pct) + "%; width: " + str(end-pct - start-pct) + "%; background: " + t.color + "; color: #1e1e1e;",
    )[#t.label]
  }
]

/// `live-demo` plus a block diagram beside it (below it on mobile),
/// showing the ordering relationship the demo is animating. `diagram`
/// is built from `group`/`track-row`.
#let live-demo-with-diagram(
  id: none,
  script: none,
  width: 680,
  height: 170,
  caption: none,
  diagram: none,
) = {
  html.div(class: "my-4 flex flex-col md:flex-row gap-4 md:items-start")[
    #html.div(class: "flex-1 min-w-0")[
      #player-block(id: id, script: script, width: width, height: height, caption: caption)
    ]
    #html.div(class: "w-full md:w-56 shrink-0 border border-text/10 rounded-lg p-2 bg-surface")[#diagram]
  ]
}
