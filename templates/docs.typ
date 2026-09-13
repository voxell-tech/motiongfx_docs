// Docs page template: sidebar + content, wider than the default page.
// Import: #import "/templates/docs.typ": docs-page

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, colors
#import "/utils/tola.typ": cls
#import "/components/docs-nav.typ": sidebar, page-nav
#import "@tola/site:0.0.0": info

#let docs-page = wrap-page(
  base: base,
  head: m => [
    #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
    #if m.title != none {
      html.title(m.title + " | " + info.title)
    } else {
      html.title(info.title)
    }
  ],
  view: (body, m) => {
    show heading.where(level: 1): it => html.h2(class: cls("text-2xl sm:text-3xl font-bold mt-8 mb-4", colors.accent))[#it.body]
    show heading.where(level: 2): it => html.h3(class: "text-lg sm:text-xl font-semibold mt-6 mb-3")[#it.body]

    // The sidebar is fixed-positioned at every size (see docs-nav.typ),
    // so it never occupies flow space here — `md:ml-64` on the content
    // column just clears the desktop rail it becomes from md: up.
    sidebar()
    html.div(class: "max-w-3xl md:ml-64 text-base")[
      #body
      #page-nav()
    ]
  },
)
