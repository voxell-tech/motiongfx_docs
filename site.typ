// The site's entry: chooses which sources under content/ become pages,
// where each one is published, and which template renders it.

#import "@tola/address:0.0.0": decode-url-path, join-route, output-of, route-of, slugify
#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources, parse-sources
#import "@tola/web:0.0.0": sitemap
#import "/templates/schema.typ": page-schema
#import "/templates/base.typ": emit
#import "/templates/page.typ": page-view
#import "/templates/docs.typ": docs-view

#set text(lang: site.language.lang)

// A page is published at the route its file path gives it
// (content/docs/bevy.typ -> /docs/bevy/), unless it sets `permalink`.
#let output-for(source) = output-of(if source.meta.permalink != none {
  decode-url-path(source.meta.permalink)
} else {
  join-route(source.route-segments.map(segment => slugify(segment)))
})

#let pages = parse-sources(all-sources(), page-schema).map(source => {
  let output = output-for(source)
  (source: source, output: output, route: route-of(output))
})

#let views = (page: page-view, docs: docs-view)

#for page in pages { emit(page, views.at(page.source.meta.layout)) }

#sitemap(targets: pages
  .filter(page => not page.source.meta.noindex)
  .map(page => page.output))
