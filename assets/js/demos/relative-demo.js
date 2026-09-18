// "Relative, Not Absolute": the dot's path, and the fact that it's a
// circle at all, are entirely encoded in Rust (see
// js_motiongfx/src/demos/relative.rs, the same source the docs page
// reads its code snippet from). This file just mounts it; drawing is
// mgfx-demo.js's generic shape renderer.
import { mountDemo, RelativeDemo } from "/js/mgfx-demo.js";

mountDemo("#relative-demo", { demo: RelativeDemo });
