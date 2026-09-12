// Client-side syntax highlighting for statically-rendered code blocks.
//
// Typst emits plain `<pre><code data-lang="...">` with no colors; Shiki
// highlights it here with both a dark and a light theme at once, switched
// by `[data-theme]` via CSS custom properties (see
// monokai-pro-shiki.js). That avoids the mismatch of baking one static
// theme's colors into HTML that also needs to work in the other appearance.
//
// Tola's SPA router morphs the page body on navigation and never re-runs
// an already-loaded external script, so this re-scans on `tola:navigate`
// instead of only running once.
import { monokaiPro, monokaiProLight, installShikiDualTheme } from "/scripts/monokai-pro-shiki.js";

installShikiDualTheme();

let highlighterReady = null;

function loadHighlighter() {
  highlighterReady ??= import("https://esm.sh/shiki@1").then(({ createHighlighter }) =>
    createHighlighter({
      themes: [monokaiPro, monokaiProLight],
      langs: ["rust", "toml", "bash"],
    }),
  );
  return highlighterReady;
}

// Typst renders line breaks in raw blocks as `<br>` elements, not `\n`
// characters. `.textContent` drops `<br>`s entirely, so read it off a
// clone with each `<br>` swapped for a real newline first.
function sourceText(code) {
  const clone = code.cloneNode(true);
  clone.querySelectorAll("br").forEach((br) => br.replaceWith("\n"));
  return clone.textContent;
}

function highlight() {
  const blocks = document.querySelectorAll("pre code[data-lang]");
  if (blocks.length === 0) return;

  loadHighlighter()
    .then((highlighter) => {
      blocks.forEach((code) => {
        const pre = code.closest("pre");
        if (!pre) return;
        try {
          pre.outerHTML = highlighter.codeToHtml(sourceText(code), {
            lang: code.dataset.lang,
            themes: { dark: "monokai-pro", light: "monokai-pro-light" },
            defaultColor: false,
          });
        } catch (err) {
          console.error("syntax highlight: codeToHtml failed:", err);
        }
      });
    })
    .catch((err) => {
      console.error("syntax highlight: failed to load Shiki:", err);
    });
}

highlight();
document.addEventListener("tola:navigate", highlight);
