// `flow`: a row of circles, each starting cs(15) = 0.15s after the
// previous one starts (not after it finishes), so a wave ripples
// through the row instead of them moving in lockstep.
import { Ease, flow, mountDemo } from "/js/mgfx-demo.js";
import { Circle, World } from "/js/shapes.js";

let world;

mountDemo("#ordering-flow-demo", {
  build: (mgfx) => {
    world = new World();
    const count = 5;
    const circles = Array.from({ length: count }, (_, i) => {
      const x = 60 + (560 / (count - 1)) * i;
      return world.add(new Circle(mgfx, `c${i}`, { x, y: 140, radius: 16, fill: "#78dce8" }));
    });
    return flow(0.15, circles.map((c) => c.y(30, 0.6, Ease.CubicInOut)));
  },
  draw: (ctx) => world.draw(ctx),
});
