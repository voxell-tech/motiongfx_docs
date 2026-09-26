#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, colors
#import "/utils/tola.typ": cls
#import "@tola/site:0.0.0": info

#let page = wrap-page(
  base: base,
  head: m => [
    #html.elem("meta", attrs: (
      name: "viewport",
      content: "width=device-width, initial-scale=1",
    ))
    #let full-title = if m.title != none {
      m.title + " | " + info.title
    } else { info.title }
    #html.title(full-title)
    // Tola's `auto_og` emits og:description but not og:title, so link
    // previews (Discord, social) would otherwise show no page name.
    #html.elem("meta", attrs: (property: "og:title", content: full-title))
  ],
  view: (body, m) => {
    show heading.where(level: 1): it => html.h2(class: cls(
      "text-2xl font-bold mt-8 mb-4",
      colors.accent,
    ))[#it.body]
    show heading.where(level: 2): it => html.h3(
      class: "text-xl font-semibold mt-6 mb-3",
    )[#it.body]
    body
  },
)
