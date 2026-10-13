// Base template with shared configuration and layout
// Import: #import "/templates/base.typ": base, colors, emit

#import "@tola/address:0.0.0": url-of-asset
#import "@tola/site:0.0.0": site
#import "/templates/seo.typ": seo-head
#import "/utils/tola.typ": cls
#import "/components/ui.typ" as ui
#import "/shared/components/nav.typ": nav
#import "/shared/components/footer.typ": footer
#import "/shared/links.typ": links

#let colors = (
  accent: "text-accent",
  code: "text-purple",
  muted: "text-muted",
)

// `current`: the route of the page being rendered (e.g. "/docs/bevy/"),
// which the nav uses to mark its active link.
#let base(current, body) = {
  show list: it => html.ul(class: "list-disc ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]
  show enum: it => html.ol(class: "list-decimal ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]

  show raw.where(block: false): it => html.code(class: cls(
    "font-semibold",
    colors.code,
  ))[#it.text]

  // Code blocks are highlighted at build time with Monokai Pro, so the
  // colors are in the HTML from the first paint (no client-side
  // highlighter to wait on). Light mode remaps the colors in CSS; see
  // the "Syntax highlighting" block in assets/styles/tailwind.css.
  set raw(theme: "/templates/monokai-pro.tmTheme")

  // The block's own background comes from shared/styles.css's `pre`;
  // this wrapper is just for margin and the border.
  show raw.where(block: true): it => html.div(
    class: "my-2 border border-text/10 rounded-lg",
  )[#it]

  show quote: it => html.blockquote(class: cls(
    "border-l-4 border-accent pl-4 my-4 italic",
    colors.muted,
  ))[#it.body]
  show link: it => {
    let href = repr(it.dest).replace("\"", "")
    let external = href.starts-with("http")
    html.a(
      class: cls("underline underline-offset-4", "hover:" + colors.accent),
      href: href,
      ..if external { (target: "_blank", rel: ("noopener", "noreferrer")) },
    )[#it.body]
  }

  // Both badges match the page's own dark-mode bg (#19181a) instead of
  // shields.io's default color, so they blend into the nav instead of
  // showing a boxed background: shields.io has no true transparent
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

  // A call to action rather than a stat like the two badges above, so it
  // gets its own pill instead of shields.io styling, with a text label
  // since there's no universally recognized "donate" glyph.
  let donate-button = html.span(
    class: "px-2.5 py-1 rounded-md border-2 border-red/40 bg-red text-white text-sm font-medium hover:opacity-90 transition-opacity",
  )[♥ Donate]

  // Mask-tinted icon, same technique the shared footer's social links use
  // (see shared/components/social.typ and .social-icon in styles.css):
  // it recolors via `background-color` instead of baking in a fixed
  // color, so it inherits hover/theme changes the way text links do.
  let nav-icon(icon, label) = html.elem("span", attrs: (
    class: "social-icon",
    style: "--icon: url('/icons/" + icon + "')",
  ))[#html.span(class: "sr-only")[#label]]

  nav(
    brand: html.span(class: "font-semibold text-text")[Home],
    gap: "gap-3",
    current: current,
    links: (
      (label: [Docs], href: "/docs/", match: "/docs"),
      (
        label: github-badge,
        href: "https://github.com/voxell-tech/motiongfx",
        external: true,
      ),
      (label: discord-badge, href: links.discord, external: true),
      (
        label: donate-button,
        // MotionGfx's own OpenCollective project, not the umbrella
        // Voxell page (links.opencollective): donations here go
        // specifically toward this project, not Voxell as a whole.
        href: "https://opencollective.com/voxell/projects/motiongfx",
        external: true,
      ),
      (
        label: nav-icon("voxell.svg", "Voxell"),
        href: links.website,
        external: true,
      ),
    ),
  )

  // Every page (docs and home alike) gets the same wide container; each
  // page's own content narrows individual reading columns where it
  // wants to (docs.typ's prose column, the landing page's hero/prose
  // sections), rather than the page shell doing it for them.
  html.main(class: "max-w-7xl mx-auto px-4 py-8")[#body]

  footer()

  html.elem("script", attrs: (type: "module", src: "/js/demo-bootstrap.js"))[]
  html.elem("script", attrs: (type: "module", src: "/js/docs-nav.js"))[]
  html.elem("script", attrs: (type: "module", src: "/js/newsletter.js"))[]
  html.elem("script", attrs: (type: "module", src: "/js/newsletter-popup.js"))[]
}

/// Write one page to its output file as a complete HTML document.
///
/// - page: one `(source:, output:, route:)` record from site.typ.
/// - view: the page's template, `(page, body) => content`, such as
///   templates/page.typ's `page-view`.
#let emit(page, view) = document(page.output, format: "html")[
  #html.html(lang: site.language.tag)[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.link(
        rel: "icon",
        href: url-of-asset("/favicon.ico"),
        type: "image/x-icon",
      )
      #html.link(rel: "stylesheet", href: url-of-asset("/styles/tailwind.css"))
      #html.meta(name: "darkreader-lock", content: "")
      // Not deferred: it sets the theme before first paint.
      #html.script("", src: "/scripts/theme.js")
      #seo-head(page)
    ]
    #html.body[
      #show: base.with(page.route)
      #view(page, include page.source.file)
    ]
  ]
]
