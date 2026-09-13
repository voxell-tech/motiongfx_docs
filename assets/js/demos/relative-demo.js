// "Relative, Not Absolute": a `Vec2` signal moves diagonally, three
// times, each in a different direction (a zigzag, not one straight
// line), with each step reading the current position and building on
// it, not jumping to three fixed, hand-picked spots.
import { Ease, chain, mountDemo, vec2Signal } from "/js/mgfx-demo.js";
import { World } from "/js/shapes.js";

const STEPS = [
  { dx: 180, dy: 50 },
  { dx: 180, dy: -100 },
  { dx: 180, dy: 50 },
];

let world;

mountDemo("#relative-demo", {
  build: (mgfx) => {
    world = new World();

    const pos = vec2Signal(mgfx, "dot", { x: 60, y: 85 });
    const radius = 16;
    world.add({
      draw(ctx) {
        ctx.beginPath();
        ctx.arc(pos.x(), pos.y(), radius, 0, Math.PI * 2);
        ctx.fillStyle = "#78dce8";
        ctx.fill();
      },
    });

    let x = 60;
    let y = 85;
    return chain(
      STEPS.map(({ dx, dy }) => pos({ x: x += dx, y: y += dy }, 0.5, Ease.CubicInOut)),
    );
  },
  draw: (ctx) => world.draw(ctx),
});
