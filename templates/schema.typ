// The metadata a content page may declare with `tola-meta`. Unknown
// fields are errors, so add new ones here first.

#import "@tola/schema:0.0.0": literal, nullable, optional, schema, union

#let page-schema = schema((
  // Shown as "Title | MotionGfx" in the browser tab; `none` on the home
  // page, which is just "MotionGfx".
  title: optional(nullable(str), default: none),
  // The meta description; falls back to the site's.
  summary: optional(nullable(str), default: none),
  // Which template renders the page: templates/page.typ or
  // templates/docs.typ.
  layout: optional(union(literal("page"), literal("docs")), default: "page"),
  // Keeps the page out of search results and the sitemap.
  noindex: optional(bool, default: false),
  // Overrides the route the file's path gives the page: "/about/" is a
  // directory, "/404.html" is a file.
  permalink: optional(nullable(str), default: none),
))
