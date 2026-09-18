// "It's Just Code": the bar chart's data and the loop over it both live
// in Rust (see js_motiongfx/src/demos/bars.rs, the same source the docs
// page reads its snippet from). This file only reads each bar's sampled
// height/y back and draws it; x is pure layout, not something that
// animates, so it stays a plain JS computation from `count`.
import { BarsDemo, mountDemo } from "/js/mgfx-demo.js";

const BAR_WIDTH = 32;

mountDemo("#loop-demo", {
  demo: BarsDemo,
  draw: (ctx, bars) => {
    const heights = bars.heights();
    const ys = bars.ys();
    const count = bars.count;

    ctx.fillStyle = "#78dce8";
    for (let i = 0; i < count; i++) {
      const x = 40 + (600 / (count - 1)) * i;
      ctx.fillRect(x - BAR_WIDTH / 2, ys[i] - heights[i] / 2, BAR_WIDTH, heights[i]);
    }
  },
});
