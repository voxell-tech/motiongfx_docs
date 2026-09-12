// A tiny toy scene for the docs site's demos: shapes with animatable
// position, size, and color, drawn with native Canvas 2D. Not a general
// graphics library, just enough to keep demos declarative instead of
// each one hand-rolling its own `ctx` calls.
import { signal } from "./mgfx-demo.js";

/** Interpolates two `[r, g, b]` colors at `t` (0..1), as a CSS color string. */
export function lerpColor(t, [r0, g0, b0], [r1, g1, b1]) {
  const r = Math.round(r0 + (r1 - r0) * t);
  const g = Math.round(g0 + (g1 - g0) * t);
  const b = Math.round(b0 + (b1 - b0) * t);
  return `rgb(${r}, ${g}, ${b})`;
}

function resolveFill(fill) {
  return typeof fill === "function" ? fill() : fill;
}

/** A filled circle. `fill` is a CSS color string, or a `() => string` for an animated color. */
export class Circle {
  constructor(mgfx, name, { x, y, radius, fill }) {
    this.x = signal(mgfx, `${name}.x`, x);
    this.y = signal(mgfx, `${name}.y`, y);
    this.radius = signal(mgfx, `${name}.radius`, radius);
    this.fill = fill;
  }

  draw(ctx) {
    ctx.beginPath();
    ctx.arc(this.x(), this.y(), this.radius(), 0, Math.PI * 2);
    ctx.fillStyle = resolveFill(this.fill);
    ctx.fill();
  }
}

/** A filled rectangle, positioned by its center. Same `fill` rules as `Circle`. */
export class Rect {
  constructor(mgfx, name, { x, y, width, height, fill }) {
    this.x = signal(mgfx, `${name}.x`, x);
    this.y = signal(mgfx, `${name}.y`, y);
    this.width = signal(mgfx, `${name}.width`, width);
    this.height = signal(mgfx, `${name}.height`, height);
    this.fill = fill;
  }

  draw(ctx) {
    ctx.fillStyle = resolveFill(this.fill);
    ctx.fillRect(
      this.x() - this.width() / 2,
      this.y() - this.height() / 2,
      this.width(),
      this.height(),
    );
  }
}

/** A group of shapes, drawn in order. */
export class World {
  constructor() {
    this.shapes = [];
  }

  /** Adds `shape` to the world and returns it, for `const c = world.add(new Circle(...))`. */
  add(shape) {
    this.shapes.push(shape);
    return shape;
  }

  draw(ctx) {
    for (const shape of this.shapes) shape.draw(ctx);
  }
}
