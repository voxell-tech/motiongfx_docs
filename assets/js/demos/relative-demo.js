// "Relative, Not Absolute": the dot's path is entirely computed in Rust
// (see js_motiongfx/src/demos/relative.rs, the same source the docs page
// reads its code snippet from); this file only reads the sampled
// position back and draws it.
import { mountDemo, RelativeDemo } from "/js/mgfx-demo.js";

const RADIUS = 16;

mountDemo("#relative-demo", {
  demo: RelativeDemo,
  draw: (ctx, dot) => {
    ctx.beginPath();
    ctx.arc(dot.x, dot.y, RADIUS, 0, Math.PI * 2);
    ctx.fillStyle = "#78dce8";
    ctx.fill();
  },
});
