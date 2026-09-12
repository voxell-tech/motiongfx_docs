// `chain`: the second circle only starts moving once the first arrives.
import { Ease, chain, mountDemo } from "/js/mgfx-demo.js";
import { Circle, World } from "/js/shapes.js";

let world;

mountDemo("#ordering-chain-demo", {
  build: (mgfx) => {
    world = new World();
    const a = world.add(new Circle(mgfx, "a", { x: 60, y: 50, radius: 16, fill: "#78dce8" }));
    const b = world.add(new Circle(mgfx, "b", { x: 60, y: 120, radius: 16, fill: "#ab9df2" }));
    return chain([
      a.x(620, 1.0, Ease.CubicInOut),
      b.x(620, 1.0, Ease.CubicInOut),
    ]);
  },
  draw: (ctx) => world.draw(ctx),
});
