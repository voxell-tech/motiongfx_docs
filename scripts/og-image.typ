// Social preview card (Open Graph / Twitter), 1200x630 at 1pt = 1px.
// Regenerate after editing:
//   typst compile --ppi 72 scripts/og-image.typ assets/images/og.png
// Colors are the site's dark-theme tokens (shared/styles.css).

#set page(width: 1200pt, height: 630pt, margin: 0pt, fill: rgb("#19181a"))
#set text(font: "Helvetica Neue", fill: rgb("#fcfcfa"))

#let accent = rgb("#78dce8")
#let muted = rgb("#939293")

#align(center + horizon, stack(
  dir: ttb,
  spacing: 30pt,
  text(size: 150pt, weight: "bold", tracking: -3pt)[Motion#text(fill: accent)[Gfx]],
  text(size: 38pt, fill: muted)[A backend agnostic motion graphics creation framework.],
  text(size: 28pt, fill: accent)[Free and open-source forever · Rust],
))

#place(bottom + center, dy: -40pt)[
  #text(size: 24pt, fill: muted)[motiongfx.voxell.dev]
]
