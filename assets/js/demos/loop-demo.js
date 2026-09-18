// "It's Just Code": the bar chart's data, layout, and the loop over it
// all live in Rust (see js_motiongfx/src/demos/bars.rs, the same
// source the docs page reads its snippet from) and come back as plain
// rects. This file just mounts it; drawing is mgfx-demo.js's generic
// shape renderer.
import { BarsDemo, mountDemo } from "/js/mgfx-demo.js";

mountDemo("#loop-demo", { demo: BarsDemo });
