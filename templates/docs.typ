// Docs page template: sidebar + content, wider than the default page.
// Used by pages that declare `layout: "docs"`.

#import "/templates/base.typ": colors
#import "/utils/tola.typ": cls
#import "/components/docs-nav.typ": page-nav, sidebar

#let docs-view(page, body) = {
  show heading.where(level: 1): it => html.h2(class: cls(
    "text-2xl sm:text-3xl font-bold mt-8 mb-4",
    colors.accent,
  ))[#it.body]
  show heading.where(level: 2): it => html.h3(
    class: "text-lg sm:text-xl font-semibold mt-6 mb-3",
  )[#it.body]

  // The sidebar is fixed-positioned at every size (see docs-nav.typ),
  // so it never occupies flow space here; `md:ml-64` on the content
  // column just clears the desktop rail it becomes from md: up.
  sidebar(page.route)
  html.div(class: "max-w-3xl md:ml-64 text-base")[
    #body
    #page-nav(page.route)
  ]
}
