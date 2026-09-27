// UI components
// Import: #import "/components/ui.typ" as ui

/// The newsletter `<form>` itself, posting straight to Kit (form
/// 9965001). A plain form, not Kit's embed script: that script ships its
/// own light-only styling, and Tola's SPA navigation never re-runs
/// inserted `<script>`s anyway. Styled with the site's own tokens, so it
/// follows the theme toggle. assets/js/newsletter.js upgrades every
/// `.newsletter-form` to submit in place; with no JS it still works, it
/// just lands on Kit's hosted confirmation page. `field-bg` is the
/// input's background, so it contrasts with whatever it sits on.
#let newsletter-form(layout: "flex flex-col sm:flex-row gap-2", field-bg: "bg-surface") = html.elem("form", attrs: (
  class: "newsletter-form " + layout,
  action: "https://app.kit.com/forms/9965001/subscriptions",
  method: "post",
))[
  #html.elem("input", attrs: (
    type: "email",
    name: "email_address",
    required: "",
    placeholder: "you@example.com",
    aria-label: "Email address",
    class: "flex-1 min-w-0 px-4 py-2.5 rounded-lg text-text border border-text/15 placeholder:text-muted focus:outline-none focus:border-accent " + field-bg,
  ))
  #html.elem("button", attrs: (
    type: "submit",
    class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity cursor-pointer disabled:opacity-50",
  ))[Subscribe]
]

/// Newsletter signup section for the landing page.
#let newsletter() = html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "max-w-xl mx-auto text-center")[
    #html.h2(class: "text-3xl font-bold mb-2")[Get Updates by Email]
    #html.p(class: "text-muted text-lg mb-6")[
      We'll email you when MotionGfx or Moxie has something new.
    ]
    #newsletter-form()
    #html.p(class: "newsletter-status text-sm text-muted mt-3")[
      No spam. Unsubscribe anytime.
    ]
  ]
]

/// The same signup as a small popup: a card centered along the bottom
/// edge from sm: up (inset-x-0 plus auto margins, not a translate, since
/// the slide-in animation already owns `translate`), a thin bar along
/// the bottom edge below that. Starts
/// hidden; assets/js/newsletter-popup.js decides when (and whether) to
/// show it. Not a modal: it never takes focus or blocks the page.
#let newsletter-popup() = html.elem("aside", attrs: (
  class: "newsletter-popup fixed z-40 inset-x-0 bottom-0 sm:mx-auto sm:bottom-6 sm:w-[22rem] bg-surface border-t-2 sm:border-2 border-accent/60 sm:rounded-lg shadow-xl shadow-accent/10 p-3 sm:p-4 transition duration-300 translate-y-4 opacity-0 data-open:translate-y-0 data-open:opacity-100 motion-reduce:transition-none",
  aria-label: "Newsletter signup",
  hidden: "",
))[
  #html.div(class: "flex items-start justify-between gap-2 mb-3")[
    #html.div(class: "flex items-start gap-2.5")[
      // Mail icon, so it reads as a signup before anyone reads the words.
      #html.elem("svg", attrs: (
        class: "shrink-0 mt-0.5 text-accent",
        width: "20",
        height: "20",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke-width: "2",
        stroke-linecap: "round",
        stroke-linejoin: "round",
        aria-hidden: "true",
      ))[
        #html.elem("rect", attrs: (x: "2", y: "4", width: "20", height: "16", rx: "2"))[]
        #html.elem("path", attrs: (d: "m22 7-10 6L2 7"))[]
      ]
      #html.div[
        #html.p(class: "text-base font-bold text-text leading-tight")[
          Get Updates by Email
        ]
        #html.p(class: "text-xs text-muted mt-0.5 max-sm:hidden")[
          MotionGfx and Moxie news, now and then.
        ]
      ]
    ]
    #html.elem("button", attrs: (
      type: "button",
      class: "newsletter-popup-close shrink-0 text-muted hover:text-text transition-colors cursor-pointer bg-transparent border-0 p-0 leading-none",
      aria-label: "Close",
    ))[#html.elem("svg", attrs: (
      width: "14",
      height: "14",
      viewBox: "0 0 16 16",
      fill: "none",
      stroke: "currentColor",
      stroke-width: "2",
      stroke-linecap: "round",
    ))[
      #html.elem("line", attrs: (x1: "2", y1: "2", x2: "14", y2: "14"))[]
      #html.elem("line", attrs: (x1: "14", y1: "2", x2: "2", y2: "14"))[]
    ]]
  ]
  #html.div[
    #newsletter-form(layout: "flex gap-2", field-bg: "bg-bg")
    #html.p(class: "newsletter-status text-xs text-muted mt-2 max-sm:hidden")[
      No spam. Unsubscribe anytime.
    ]
  ]
]

/// Card container
#let card(title: none, body) = html.div(class: "p-4 bg-surface rounded-lg")[
  #if title != none { html.h3(class: "font-semibold text-accent mb-2")[#title] }
  #body
]

/// Reads a Rust source file and pulls out the region between a
/// `// snippet:start` and a `// snippet:end` comment, dedented to that
/// region's own smallest indent. Used so a demo's code block is the
/// literal source that got compiled into the page's wasm, not a
/// hand-copied paraphrase of it that can quietly drift out of sync;
/// see js_motiongfx/src/demos/relative.rs for the marker convention.
#let rust-snippet(path) = {
  let source = read(path)
  let start-marker = "// snippet:start"
  let end-marker = "// snippet:end"
  let start = source.position(start-marker)
  let end = source.position(end-marker)
  assert(
    start != none and end != none,
    message: "rust-snippet: couldn't find " + start-marker + "/" + end-marker + " in " + path,
  )

  let lines = source.slice(start + start-marker.len(), end).split("\n")
  if lines.len() > 0 and lines.first().trim() == "" { lines = lines.slice(1) }
  if lines.len() > 0 and lines.last().trim() == "" { lines = lines.slice(0, -1) }

  let leading-spaces(line) = {
    let n = 0
    for c in line.codepoints() {
      if c != " " { break }
      n += 1
    }
    n
  }

  let indents = lines.filter(l => l.trim() != "").map(leading-spaces)
  let min-indent = if indents.len() > 0 { calc.min(..indents) } else { 0 }
  let dedented = lines.map(l => if l.len() >= min-indent { l.slice(min-indent) } else { l })

  raw(dedented.join("\n"), lang: "rust", block: true)
}

/// Side-by-side showcase card: source code + rendered output. Two
/// columns from md: up (stacked below that, where there's no room to
/// put them side by side); pass `reverse: true` to swap which side the
/// preview lands on, e.g. alternating across a page's sections so they
/// don't all read the same direction.
#let showcase-demo(
  title: none,
  description: none,
  code: none,
  preview: none,
  code-label: "Typst Code",
  preview-label: "Rendered Output",
  reverse: false,
) = {
  assert(title != none, message: "showcase-demo: `title` is required")
  assert(code != none, message: "showcase-demo: `code` is required")
  assert(preview != none, message: "showcase-demo: `preview` is required")

  let code-order = if reverse { "md:order-2" } else { "md:order-1" }
  let preview-order = if reverse { "md:order-1" } else { "md:order-2" }

  html.section(
    class: "my-8 rounded-lg bg-gradient-to-br from-bg/80 via-bg/50 to-surface/20 p-4 sm:p-6",
  )[
    #html.div(class: "mb-4")[
      #html.h3(class: "text-3xl font-bold mb-2")[
        #title
      ]
      #if description != none {
        html.p(class: "mt-1 text-sm text-subtle")[
          #description
        ]
      }
    ]

    #html.div(class: "grid gap-4 md:grid-cols-2 md:items-stretch")[
      #html.div(
        class: "rounded-lg border border-text/10 bg-bg/70 overflow-hidden "
          + code-order,
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
        class: "rounded-lg border border-accent/30 bg-surface/40 overflow-hidden "
          + preview-order,
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
#let player-block(
  id: none,
  script: none,
  label: "Live MotionGfx animation",
  width: 680,
  height: 170,
  caption: none,
) = {
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
        role: "img",
        aria-label: label,
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
#let live-demo(
  id: none,
  script: none,
  width: 680,
  height: 170,
  caption: none,
) = {
  html.div(class: "my-4")[
    #player-block(
      id: id,
      script: script,
      width: width,
      height: height,
      caption: caption,
    )
  ]
}

/// A small labeled box drawn around one level of a combinator's
/// nesting, e.g. `ui.group(label: "chain")[#ui.group(label: "all")[...]
/// #ui.track-row(...)]` for `chain([all([...]), frag_c])`, mirroring
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
        style: "left: "
          + str(start-pct)
          + "%; width: "
          + str(pct(full-end) - start-pct)
          + "%; border-color: "
          + t.color
          + ";",
      )[]
    }
    html.div(
      class: "absolute inset-y-0 rounded flex items-center justify-center text-[10px] font-semibold overflow-hidden whitespace-nowrap",
      style: "left: "
        + str(start-pct)
        + "%; width: "
        + str(end-pct - start-pct)
        + "%; background: "
        + t.color
        + "; color: #1e1e1e;",
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
      #player-block(
        id: id,
        script: script,
        width: width,
        height: height,
        caption: caption,
      )
    ]
    #html.div(
      class: "w-full md:w-56 shrink-0 border border-text/10 rounded-lg p-2 bg-surface",
    )[#diagram]
  ]
}
