// `delay`: the circle sits still for cs(30) = 0.3s before it starts moving.
import { Ease, delay, mountDemo } from "/js/mgfx-demo.js";
import { Circle, World } from "/js/shapes.js";

let world;

mountDemo("#ordering-delay-demo", {
  build: (mgfx) => {
    world = new World();
    const a = world.add(new Circle(mgfx, "a", { x: 60, y: 85, radius: 16, fill: "#78dce8" }));
    return delay(0.3, a.x(620, 1.0, Ease.CubicInOut));
  },
  draw: (ctx) => world.draw(ctx),
});
