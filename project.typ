// What the shared site kit (shared/site/) needs to know about
// MotionGfx. The site's title, description, and origin live in
// tola.toml's [site].
#let project = (
  repo: "https://github.com/voxell-tech/motiongfx",
  // SPDX identifier, for the home page's schema.org data.
  license: "MIT",
  // MotionGfx's own OpenCollective project, not the umbrella Voxell
  // page: donations here go specifically toward this project.
  donate: "https://opencollective.com/voxell/projects/motiongfx",
  // Social preview card, 1200x630 (assets/images/og.png, made from
  // scripts/og-image.typ). Bump `v` whenever the image changes:
  // Discord, X, and others cache preview images by URL, so the same
  // URL keeps showing the old card.
  og-image: "/images/og.png?v=2",
  // The docs sidebar, in reading order: what previous/next walk.
  chapters: (
    (
      title: "Choose a Backend",
      items: (
        (title: "Overview", href: "/docs/"),
        (title: "Bevy MotionGfx", href: "/docs/bevy/"),
      ),
    ),
    (
      title: "Concepts",
      items: (
        (title: "Actions", href: "/docs/concepts/actions/"),
        (title: "Ordering", href: "/docs/concepts/ordering/"),
        (title: "Timeline", href: "/docs/concepts/timeline/"),
      ),
    ),
    (
      title: "Advanced",
      items: (
        (title: "Building a Backend", href: "/docs/advanced/"),
      ),
    ),
  ),
  // Loaded on every page, after the kit's own scripts.
  scripts: (),
)

// The Kit newsletter form, shared with Moxie's news.
#let newsletter-form = "9965001"
