// Docs sidebar data and component.
// Import: #import "/components/docs-nav.typ": sidebar

#import "@tola/current:0.0.0": current-permalink

#let groups = (
  (
    title: "Choose a Backend",
    items: (
      (title: "Overview", href: "/docs"),
      (title: "Bevy MotionGfx", href: "/docs/bevy"),
    ),
  ),
  (
    title: "Concepts",
    items: (
      (title: "Actions", href: "/docs/concepts/actions"),
      (title: "Ordering", href: "/docs/concepts/ordering"),
      (title: "Timeline", href: "/docs/concepts/timeline"),
    ),
  ),
  (
    title: "Advanced",
    items: (
      (title: "Building a Backend", href: "/docs/advanced"),
    ),
  ),
)

// Canonical permalinks end in "/" (e.g. "/docs/bevy/"); hrefs above don't.
// Strip a trailing slash from both sides before comparing.
#let norm(path) = if path != none and path != "/" and path.ends-with("/") {
  path.slice(0, -1)
} else {
  path
}

// `md:order-first`: on mobile this renders after the page content (so
// people scroll to content first, not a wall of nav links), then moves
// back to its usual left column on wider screens.
#let sidebar() = html.nav(
  class: "w-full md:w-48 shrink-0 md:sticky md:top-8 md:order-first text-sm",
)[
  #for group in groups {
    html.div(class: "mb-6 last:mb-0")[
      #html.div(
        class: "font-semibold text-subtle uppercase tracking-wide text-xs mb-2",
      )[#group.title]
      #html.div(class: "flex flex-col gap-0.5")[
        #for item in group.items {
          let active = norm(current-permalink) == norm(item.href)
          let link-class = if active {
            "block px-3 py-2 rounded-lg bg-surface text-accent font-medium"
          } else {
            "block px-3 py-2 rounded-lg text-muted hover:text-accent hover:bg-surface/50 transition-colors"
          }
          html.a(class: link-class, href: item.href)[#item.title]
        }
      ]
    ]
  }
]
