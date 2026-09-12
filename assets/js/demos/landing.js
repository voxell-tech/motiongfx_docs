// The landing page's live playground: a circle that grows and recolors.
import { Ease, all, mountDemo, signal } from "/js/mgfx-demo.js";
import { Circle, World, lerpColor } from "/js/shapes.js";

const START_COLOR = [252, 152, 103]; // orange
const END_COLOR = [120, 220, 232]; // accent teal

let world, mix;

mountDemo("#landing-demo", {
  build: (mgfx) => {
    world = new World();
    mix = signal(mgfx, "mix", 0);
    const circle = world.add(
      new Circle(mgfx, "circle", {
        x: 80,
        y: 80,
        radius: 20,
        fill: () => lerpColor(mix(), START_COLOR, END_COLOR),
      }),
    );
    return all([circle.radius(70, 1.0, Ease.CubicInOut), mix(1.0, 1.0, Ease.CubicInOut)]);
  },
  draw: (ctx) => world.draw(ctx),
});
