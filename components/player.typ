// MotionGfx's live demo player and timeline diagrams.
// Import: #import "/components/player.typ" as player

/// The player itself: canvas + shell, no outer margin. Shared by
/// `live-demo` (standalone) and `live-demo-with-diagram` (beside a
/// `track-diagram`), so the margin isn't applied twice in the combined
/// layout.
///
/// `script` isn't emitted as a `<script>` tag: on Tola's SPA
/// navigation, an inserted `<script>` never executes (that's a DOM
/// morph, not a real parse), so a demo whose only page wasn't the one
/// you hard-loaded would never run. Instead the shell carries `script`
/// as `data-demo-src`, and shared/scripts/demo-bootstrap.js (loaded once,
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
/// nesting, e.g. `player.group(label: "chain")[#player.group(label:
/// "all")[...] #player.track-row(...)]` for `chain([all([...]), frag_c])`, mirroring
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
