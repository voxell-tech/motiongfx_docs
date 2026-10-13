// Everything in <head> that search engines and link previews read:
// title, description, canonical URL, Open Graph, and Twitter card tags.
// Called for every page by templates/base.typ's `emit`. This emits the
// page's own `summary` rather than the one site-wide description.
//
// Page metadata it reads (declared in templates/schema.typ):
// - `title`: shown as "Title | MotionGfx" (just "MotionGfx" if none).
// - `summary`: the meta description; falls back to the site's.
// - `noindex`: keep the page out of search results (the 404 page).

#import "/utils/tola.typ": og-tags
#import "@tola/address:0.0.0": url-of
#import "@tola/site:0.0.0": site

// Social preview card, 1200x630 (assets/images/og.png, made from
// scripts/og-image.typ). Bump `v` whenever the image changes: Discord,
// X, and others cache preview images by URL, so the same URL keeps
// showing the old card.
#let og-image = "/images/og.png?v=2"

#let seo-head(page) = {
  let m = page.source.meta
  let full-title = if m.title != none {
    m.title + " | " + site.title
  } else { site.title }
  let description = if m.summary != none { m.summary } else {
    site.description
  }
  let url = url-of(page.output, origin: site.origin)

  html.elem("meta", attrs: (
    name: "viewport",
    content: "width=device-width, initial-scale=1",
  ))
  html.title(full-title)
  html.meta(name: "description", content: description)
  html.link(rel: "canonical", href: url)
  if m.noindex {
    html.meta(name: "robots", content: "noindex")
  }
  og-tags(
    title: full-title,
    description: description,
    url: url,
    image: site.origin + og-image,
    type: "website",
    site-name: site.title,
    locale: "en_US",
  )
}
