// "Scrub Forward and Backward, for Free": the bounce itself is real
// motiongfx Rust (see js_motiongfx/src/demos/bounce.rs, the same source
// the docs page reads its snippet from); this file only reads the
// sampled y back and draws it.
import { BounceDemo, mountDemo } from "/js/mgfx-demo.js";

const X = 340;
const RADIUS = 18;

mountDemo("#bounce-demo", {
  demo: BounceDemo,
  draw: (ctx, ball) => {
    ctx.beginPath();
    ctx.arc(X, ball.y, RADIUS, 0, Math.PI * 2);
    ctx.fillStyle = "#78dce8";
    ctx.fill();
  },
});
