// Submits the newsletter form (components/ui.typ's `newsletter`) to Kit
// in place, instead of navigating away to Kit's hosted confirmation
// page. Kit's endpoint allows cross-origin POSTs. Delegated on
// `document`, like docs-nav.js, so it keeps working after Tola's SPA
// navigation swaps in a fresh copy of the form.
document.addEventListener("submit", async (event) => {
  const form = event.target.closest(".newsletter-form");
  if (!form) return;
  event.preventDefault();

  const status = form.parentElement.querySelector(".newsletter-status");
  const button = form.querySelector("button");
  button.disabled = true;

  try {
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { Accept: "application/json" },
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    form.style.display = "none";
    status.classList.replace("text-muted", "text-accent");
    status.textContent = "Success! Now check your email to confirm your subscription.";
  } catch {
    button.disabled = false;
    status.classList.replace("text-muted", "text-red");
    status.textContent = "Something went wrong. Please try again.";
  }
});
