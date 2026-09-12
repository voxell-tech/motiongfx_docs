// A more sophisticated scene than the Ordering page's toy demos: six
// circles fly in (staggered via `flow`, each growing and recoloring
// through `all`), then a synchronized bounce ripples across them
// (another `flow`, each pulsing through a `chain`). The whole thing is
// one baked `Track` under the hood, so scrubbing the player back and
// forth is exactly the "sample any time, any order" two-way playback
// this page describes, not a re-simulation.
import { Ease, all, chain, flow, mountDemo, signal } from "/js/mgfx-demo.js";
import { Circle, World, lerpColor } from "/js/shapes.js";

const FROM = [120, 220, 232]; // cyan
const TO = [171, 157, 242]; // purple

let world;

mountDemo("#timeline-showcase-demo", {
  build: (mgfx) => {
    world = new World();

    const count = 6;
    const landingY = 85;
    const spacing = 560 / (count - 1);

    const circles = Array.from({ length: count }, (_, i) => {
      const mix = signal(mgfx, `mix${i}`, 0);
      const circle = new Circle(mgfx, `c${i}`, {
        x: 60 + spacing * i,
        y: 20,
        radius: 0,
        fill: () => lerpColor(mix(), FROM, TO),
      });
      world.add(circle);
      return { circle, mix };
    });

    // Entrance: each circle grows, rises into place, and recolors all
    // at once (`all`), staggered one after another (`flow`).
    const entrance = flow(
      0.1,
      circles.map(({ circle, mix }) =>
        all([
          circle.radius(16, 0.5, Ease.CubicInOut),
          circle.y(landingY, 0.5, Ease.CubicInOut),
          mix(1, 0.5, Ease.CubicInOut),
        ]),
      ),
    );

    // Wave: once everyone's landed, a bounce ripples through the row
    // (via `flow` again) — each circle grows and flashes back toward
    // cyan (`all`), then shrinks and settles back to purple (`chain`
    // sequencing the two halves of the bounce).
    const wave = flow(
      0.08,
      circles.map(({ circle, mix }) =>
        chain([
          all([
            circle.radius(26, 0.25, Ease.SineOut),
            mix(0, 0.25, Ease.SineOut),
          ]),
          all([
            circle.radius(16, 0.25, Ease.SineIn),
            mix(1, 0.25, Ease.SineIn),
          ]),
        ]),
      ),
    );

    return chain([entrance, wave]);
  },
  draw: (ctx) => world.draw(ctx),
});
