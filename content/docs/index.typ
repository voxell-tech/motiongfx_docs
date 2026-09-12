#import "/templates/docs.typ": docs-page
#import "/components/ui.typ" as ui
#import "/components/layout.typ" as layout

#show: docs-page.with(title: "Choose a Backend")

= Choose a Backend

MotionGfx describes animations. A backend crate connects that description
to something you can actually see.

#layout.grid(
  cols: 2,
  gap: 4,
  ui.card(title: [#link("/docs/bevy")[Bevy MotionGfx →]])[
    #html.p(class: "text-muted text-sm")[
      For Bevy games and apps. A plugin handles setup: animate any
      component field on any entity.
    ]
  ],
  html.div(
    class: "flex flex-col items-start justify-center p-4 rounded-lg border border-dashed border-text/15",
  )[
    #html.p(class: "font-semibold text-subtle mb-1")[More coming soon]
    #html.p(class: "text-muted text-sm")[
      The web, other game engines, and other renderers. Building your own
      now? See #link("/docs/advanced")[Building a Backend].
    ]
  ],
)

== Then, learn the concepts

Once you can see something animate, #link("/docs/concepts/actions")[Concepts]
walks through how MotionGfx actually builds and plays an animation, one
short page at a time. It applies to every backend equally.
