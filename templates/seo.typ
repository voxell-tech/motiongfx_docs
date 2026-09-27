// Everything in <head> that search engines and link previews read:
// title, description, canonical URL, Open Graph, and Twitter card tags.
// Shared by templates/page.typ and templates/docs.typ. Tola's own
// `auto_og` is off (tola.toml), since it can only ever emit the one
// site-wide description; this emits the page's own `summary` instead.
//
// Page metadata it reads:
// - `title`: shown as "Title | MotionGfx"; with none (the home page),
//   `home-title` instead, so the tab and link previews say what it is.
// - `summary`: the meta description; falls back to the site's.
// - `noindex`: keep the page out of search results (the 404 page).

#import "/utils/tola.typ": og-tags
#import "@tola/site:0.0.0": info
#import "@tola/current:0.0.0": current-permalink

#let home-title = "MotionGfx: Backend Agnostic Motion Graphics Creation Framework"

// Social preview card, 1200x630 (assets/images/og.png).
#let og-image = "/images/og.png"

#let seo-head(m) = {
  let full-title = if m.title != none {
    m.title + " | " + info.title
  } else { home-title }
  let description = m.at("summary", default: none)
  if description == none { description = info.description }
  let site = info.url.trim("/", at: end)
  let url = site + if current-permalink != none { current-permalink } else { "/" }

  html.elem("meta", attrs: (
    name: "viewport",
    content: "width=device-width, initial-scale=1",
  ))
  html.title(full-title)
  html.meta(name: "description", content: description)
  html.link(rel: "canonical", href: url)
  if m.at("noindex", default: false) {
    html.meta(name: "robots", content: "noindex")
  }
  og-tags(
    title: full-title,
    description: description,
    url: url,
    image: site + og-image,
    type: "website",
    site-name: info.title,
    locale: "en_US",
  )
}
