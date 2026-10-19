// Tabs for components/ordering.typ's `tabs`: one combinator's panel at
// a time. Each panel's demo mounts and plays on its own (see
// mgfx-demo.js), so switching just shows another one.
//
// Loaded once by the kit's demo-bootstrap.js; the listener is on the
// document, so it keeps working across Tola's SPA navigation.
document.addEventListener("click", (event) => {
  const tab = event.target.closest(".ordering-tab");
  if (!tab) return;
  const root = tab.closest(".ordering-tabs");
  for (const other of root.querySelectorAll(".ordering-tab")) {
    other.setAttribute("aria-selected", String(other === tab));
  }
  for (const panel of root.querySelectorAll(".ordering-panel")) {
    panel.hidden = panel.dataset.panel !== tab.dataset.tab;
  }
});
