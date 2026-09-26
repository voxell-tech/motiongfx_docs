#import "/templates/page.typ": page

// GitHub Pages serves /404.html for any URL that doesn't exist. Tola
// always emits a page as <name>/index.html, so the deploy workflow
// copies this page's output to /404.html after the build.
#show: page.with(title: "Page Not Found")

#html.div(class: "text-center py-24 px-5")[
  #html.p(class: "text-accent font-semibold mb-2")[404]
  #html.h1(class: "text-4xl font-bold mb-4")[Page Not Found]
  #html.p(class: "text-muted text-lg mb-8")[
    This page doesn't exist, or it moved.
  ]
  #html.div(class: "flex flex-wrap justify-center gap-3")[
    #html.a(
      class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity",
      href: "/",
    )[Go Home]
    #html.a(
      class: "px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold hover:border-accent/50 hover:text-accent transition-colors",
      href: "/docs",
    )[Read the Docs]
  ]
]
