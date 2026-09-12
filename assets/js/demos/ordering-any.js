// `any`: both circles start together, and the group should finish the
// moment the fastest (`b`, 0.5s) does, letting the square start moving
// up early while `a` is still (supposedly) mid-flight. Compare against
// `all` above, where the square waits for both circles.
import { Ease, any, chain, mountDemo } from "/js/mgfx-demo.js";
import { Circle, Rect, World } from "/js/shapes.js";

let world;

mountDemo("#ordering-any-demo", {
  build: (mgfx) => {
    world = new World();
    const a = world.add(new Circle(mgfx, "a", { x: 60, y: 50, radius: 16, fill: "#78dce8" }));
    const b = world.add(new Circle(mgfx, "b", { x: 60, y: 120, radius: 16, fill: "#ab9df2" }));
    const c = world.add(new Rect(mgfx, "c", { x: 590, y: 140, width: 32, height: 32, fill: "#ffd866" }));
    return chain([
      any([
        a.x(420, 1.0, Ease.CubicInOut),
        b.x(420, 0.5, Ease.CubicInOut),
      ]),
      c.y(30, 0.5, Ease.CubicInOut),
    ]);
  },
  draw: (ctx) => world.draw(ctx),
});
