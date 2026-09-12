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

  let github-badge = html.elem("img", attrs: (
    src: "https://img.shields.io/github/stars/voxell-tech/motiongfx?style=flat&logo=github&label=",
    height: "20",
    alt: "GitHub stars",
    style: "display: inline-block; vertical-align: middle;",
  ))

  nav(links: (
    (label: [Docs], href: "/docs", match: "/docs"),
    (label: github-badge, href: "https://github.com/voxell-tech/motiongfx", external: true),
    (label: [Discord ↗], href: links.discord, external: true),
    (label: [Voxell ↗], href: links.website, external: true),
  ))

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
}
