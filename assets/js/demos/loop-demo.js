// "It's Just Code": ordinary loops and variables build the whole scene,
// a bar chart, one `.map()` over each bar's position and target
// height, one shared stagger variable, no special timeline UI to
// hand-place anything in.
import { Ease, all, flow, mountDemo } from "/js/mgfx-demo.js";
import { Rect, World } from "/js/shapes.js";

let world;

// The "data": how tall each bar grows to. Ordinary numbers, no special
// authoring tool needed to place them.
const HEIGHTS = [60, 110, 40, 130, 80, 150, 100, 55, 120, 70];
const BASELINE = 160;

mountDemo("#loop-demo", {
  build: (mgfx) => {
    world = new World();
    const count = HEIGHTS.length;

    const bars = HEIGHTS.map((height, i) => {
      const x = 40 + (600 / (count - 1)) * i;
      const bar = new Rect(mgfx, `bar${i}`, { x, y: BASELINE, width: 32, height: 6, fill: "#78dce8" });
      world.add(bar);
      return { bar, height };
    });

    return flow(
      0.06, // the "variable": stagger between each bar's start
      bars.map(({ bar, height }) =>
        all([
          bar.height(height, 0.6, Ease.CubicInOut),
          bar.y(BASELINE - height / 2, 0.6, Ease.CubicInOut),
        ]),
      ),
    );
  },
  draw: (ctx) => world.draw(ctx),
});
