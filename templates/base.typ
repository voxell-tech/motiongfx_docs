// Base template with shared configuration and layout
// Import: #import "/templates/base.typ": base, colors

#import "/templates/tola.typ" as tola
#import "/utils/tola.typ": cls
#import "/components/ui.typ" as ui
#import "@tola/current:0.0.0": current-permalink
#import "/shared/components/nav.typ": nav
#import "/shared/components/footer.typ": footer
#import "/shared/links.typ": links

#let colors = (
  accent: "text-accent",
  code: "text-purple",
  muted: "text-muted",
)

#let base(body) = {
  show: tola.tola-base.with(
    figure-class: "my-6 mx-auto w-fit",
    // Keep inline math in normal inline formatting context so SVG
    // `vertical-align` baseline offsets are effective.
    math-inline-class: "inline-block align-baseline text-lg",
    math-block-class: "my-6 flex justify-center text-2xl",
  )

  show list: it => html.ul(class: "list-disc ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]
  show enum: it => html.ol(class: "list-decimal ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]

  show raw.where(block: false): it => html.code(class: cls("font-semibold", colors.code))[#it.text]

  // The theme (see /js/syntax-highlight.js) sets the block's own
  // background; this wrapper is just for margin and the border.
  show raw.where(block: true): it => html.div(
    class: "my-2 border border-text/10 rounded-lg",
  )[#it]

  show quote: it => html.blockquote(class: cls("border-l-4 border-accent pl-4 my-4 italic", colors.muted))[#it.body]
  show link: it => html.a(
    class: cls("underline underline-offset-4", "hover:" + colors.accent),
    href: repr(it.dest).replace("\"", ""),
  )[#it.body]

  // Both badges match the page's own dark-mode bg (#19181a) instead of
  // shields.io's default color, so they blend into the nav instead of
  // showing a boxed background — shields.io has no true transparent
  // option (`color=transparent` and an 8-digit alpha hex both just fall
  // back to their default green), and it won't match in light mode
  // since there's no way to make a static badge image react to the
  // theme toggle. `flat-square` over `for-the-badge`: the latter bakes
  // generous internal padding into the SVG itself as part of its look,
  // which can't be stripped via CSS on an opaque <img>.
  let github-badge = html.elem("img", attrs: (
    src: "https://img.shields.io/github/stars/voxell-tech/motiongfx?style=flat-square&logo=github&logoColor=white&label=&color=19181a",
    height: "20",
    alt: "GitHub stars",
    style: "display: inline-block; vertical-align: middle;",
  ))

  let discord-badge = html.elem("img", attrs: (
    src: "https://img.shields.io/discord/442334985471655946?style=flat-square&logo=discord&logoColor=white&label=&color=19181a",
    height: "20",
    alt: "Discord online",
    style: "display: inline-block; vertical-align: middle;",
  ))

  // Mask-tinted icon, same technique the shared footer's social links use
  // (see shared/components/social.typ and .social-icon in styles.css) —
  // it recolors via `background-color` instead of baking in a fixed
  // color, so it inherits hover/theme changes the way text links do.
  let nav-icon(icon, label) = html.elem("span", attrs: (
    class: "social-icon",
    style: "--icon: url('/icons/" + icon + "')",
  ))[#html.span(class: "sr-only")[#label]]

  nav(
    brand: html.span(class: "font-semibold text-text")[Home],
    gap: "gap-3",
    links: (
      (label: [Docs], href: "/docs", match: "/docs"),
      (label: github-badge, href: "https://github.com/voxell-tech/motiongfx", external: true),
      (label: discord-badge, href: links.discord, external: true),
      (label: nav-icon("voxell.svg", "Voxell"), href: links.website, external: true),
    ),
  )

  let main-class = if current-permalink != none and current-permalink.starts-with("/docs") {
    "max-w-7xl mx-auto px-4 py-8"
  } else {
    "max-w-3xl mx-auto px-4 py-8"
  }
  html.main(class: main-class)[#body]

  // Footer on sub-pages only, not the home page.
  if current-permalink != none and current-permalink != "/" {
    footer()
  }

  html.elem("script", attrs: (type: "module", src: "/js/syntax-highlight.js"))[]
  html.elem("script", attrs: (type: "module", src: "/js/demo-bootstrap.js"))[]
  html.elem("script", attrs: (type: "module", src: "/js/docs-nav.js"))[]
}
