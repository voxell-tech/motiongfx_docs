// "Scrub Forward and Backward, for Free": a bounce, rising on one ease
// and falling on another. Drag the scrubber: playing it backward
// costs exactly the same as forward, no re-simulation either way.
import { Ease, chain, mountDemo } from "/js/mgfx-demo.js";
import { Circle, World } from "/js/shapes.js";

let world;

mountDemo("#bounce-demo", {
  build: (mgfx) => {
    world = new World();
    const ball = world.add(new Circle(mgfx, "ball", { x: 340, y: 140, radius: 18, fill: "#78dce8" }));

    return chain([
      ball.y(30, 0.6, Ease.QuadOut),
      ball.y(140, 0.6, Ease.QuadIn),
    ]);
  },
  draw: (ctx) => world.draw(ctx),
});
