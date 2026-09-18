// "Scrub Forward and Backward, for Free": the bounce itself, and the
// fact that it's a circle, are entirely encoded in Rust (see
// js_motiongfx/src/demos/bounce.rs, the same source the docs page
// reads its snippet from). This file just mounts it; drawing is
// mgfx-demo.js's generic shape renderer.
import { BounceDemo, mountDemo } from "/js/mgfx-demo.js";

mountDemo("#bounce-demo", { demo: BounceDemo });
