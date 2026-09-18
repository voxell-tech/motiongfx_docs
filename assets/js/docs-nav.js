// Keeps the docs "Chapters" <details> (components/docs-nav.typ) open on
// desktop. A closed <details>'s content is hidden by the browser itself
// (per the HTML spec's own `details:not([open]) > :not(summary)` rule),
// and that isn't something a plain CSS override can be relied on to
// beat consistently across engines, so this sets `.open` directly
// instead, based on viewport width, the same way theme-toggle.js and
// friends handle their own bit of persistent interactive state.
//
// Mobile is left alone on load/navigation: no `open` there by default
// (collapsed, tap the summary to expand), and `openOnDesktop` never
// sets it back to false, so it won't fight a mobile visitor's own
// toggling mid-session.
const isDesktop = window.matchMedia("(min-width: 768px)");

function openOnDesktop() {
  if (!isDesktop.matches) return;
  document.querySelectorAll(".docs-nav").forEach((details) => {
    details.open = true;
  });
}

// Crossing the breakpoint itself has to go both ways, though: resizing
// from desktop down to mobile needs to actually clear the `open`
// attribute desktop set, not just leave it (that attribute doesn't
// know the viewport shrank, so the drawer would render open on mobile
// otherwise: this is the one place it's set to false explicitly).
function syncOnBreakpointChange() {
  document.querySelectorAll(".docs-nav").forEach((details) => {
    details.open = isDesktop.matches;
  });
}

openOnDesktop();
isDesktop.addEventListener("change", syncOnBreakpointChange);
document.addEventListener("tola:navigate", openOnDesktop);

// Closing the mobile drawer: its own close button, the dimmed backdrop,
// or picking a chapter link. Delegated on `document` so it keeps
// working after Tola morphs in a new page's (new) drawer instance.
// Harmless on desktop too: `tola:navigate` re-opens it right after via
// `openOnDesktop` above.
function stripTrailingSlash(path) {
  return path !== "/" && path.endsWith("/") ? path.slice(0, -1) : path;
}

document.addEventListener("click", (event) => {
  const closer = event.target.closest(".docs-nav-close, .docs-nav-backdrop, .docs-nav-body a");
  if (!closer) return;

  // A link to the page already open doesn't navigate (Tola's router has
  // nowhere to go), so `tola:navigate` never fires afterward to reopen
  // the drawer; closing it here would leave it stuck shut with no event
  // left to undo that. Leave it alone instead.
  if (closer.tagName === "A" && stripTrailingSlash(closer.pathname) === stripTrailingSlash(location.pathname)) {
    return;
  }

  closer.closest(".docs-nav")?.removeAttribute("open");
});
