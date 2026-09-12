// End-to-end smoke test, run via `deno run`: signals, literal and
// function transforms, easing, ordering, and two-way playback.
import { all, chain, delay, Ease, Runtime, signal, vec2Signal } from "./runtime.ts";

let failures = 0;
function check(label: string, actual: number, expected: number, eps = 1e-6) {
  const ok = Math.abs(actual - expected) <= eps;
  console.log(`${ok ? "ok " : "FAIL"} ${label}: got ${actual}, expected ${expected}`);
  if (!ok) failures++;
}

// Basic literal transform, single action
{
  const mgfx = new Runtime();
  const radius = signal(mgfx, "radius", 20);
  mgfx.compile(radius(70, 1.0));

  check("duration", mgfx.duration, 1.0);

  mgfx.sampleAt(0);
  check("radius at t=0", radius(), 20);

  mgfx.sampleAt(0.5);
  check("radius at t=0.5", radius(), 45);

  mgfx.sampleAt(1.0);
  check("radius at t=1.0", radius(), 70);

  // Two-way playback: sample backward off the same bake.
  mgfx.sampleAt(0.25);
  check("radius at t=0.25 (scrubbed backward)", radius(), 32.5);
}

// Function transform (relative change)
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "x", 10);
  mgfx.compile(x((current) => current + 5, 1.0));

  mgfx.sampleAt(1.0);
  check("x at t=1.0 (relative +5)", x(), 15);
}

// `all`: two subjects animating together
{
  const mgfx = new Runtime();
  const radius = signal(mgfx, "radius", 20);
  const mix = signal(mgfx, "mix", 0);
  mgfx.compile(all([radius(70, 1.0), mix(1.0, 1.0)]));

  mgfx.sampleAt(0.5);
  check("radius at t=0.5 (all)", radius(), 45);
  check("mix at t=0.5 (all)", mix(), 0.5);
}

// `chain`: second action starts when the first finishes
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "x", 0);
  mgfx.compile(chain([x(10, 1.0), x(0, 1.0)]));

  check("chain duration", mgfx.duration, 2.0);
  mgfx.sampleAt(0.5);
  check("x at t=0.5 (chain, mid first leg)", x(), 5);
  mgfx.sampleAt(1.5);
  check("x at t=1.5 (chain, mid second leg)", x(), 5);
  mgfx.sampleAt(2.0);
  check("x at t=2.0 (chain, end)", x(), 0);
}

// Easing changes the curve, not the endpoints
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "x", 0);
  mgfx.compile(x(100, 1.0, Ease.CubicInOut));

  mgfx.sampleAt(0);
  check("eased x at t=0", x(), 0);
  mgfx.sampleAt(1.0);
  check("eased x at t=1.0", x(), 100);
  mgfx.sampleAt(0.5);
  // cubicInOut(0.5) == 0.5 exactly (symmetric), so midpoint is unaffected.
  check("eased x at t=0.5", x(), 50);
}

// `delay`: pushes a single fragment's start later
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "x", 0);
  mgfx.compile(delay(1.0, x(10, 1.0)));

  check("delay duration", mgfx.duration, 2.0);
  mgfx.sampleAt(0.5);
  check("x at t=0.5 (still delayed)", x(), 0);
  mgfx.sampleAt(1.5);
  check("x at t=1.5 (mid, after delay)", x(), 5);
}

// A Vec2: every subject is a plain `f64`, so a compound value is just
// one signal per component, animated together with `all`.
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "pos.x", 0);
  const y = signal(mgfx, "pos.y", 0);
  mgfx.compile(all([x(100, 1.0), y(50, 1.0, Ease.CubicInOut)]));

  mgfx.sampleAt(0.5);
  const pos = { x: x(), y: y() };
  check("pos.x at t=0.5 (vec2)", pos.x, 50);
  check("pos.y at t=0.5 (vec2, eased)", pos.y, 25);
}

// `vec2Signal`: the compound version, matching Motion Canvas's
// `transform.position.x(...)` shape. `pos(...)` sets both axes at once;
// `pos.x`/`pos.y` are the same two `Signal`s, addressable independently.
{
  const mgfx = new Runtime();
  const pos = vec2Signal(mgfx, "pos", { x: 0, y: 0 });
  mgfx.compile(pos({ x: 100, y: 50 }, 1.0, Ease.CubicInOut));

  mgfx.sampleAt(0.5);
  const at = pos();
  check("pos().x at t=0.5 (compound read)", at.x, 50);
  check("pos().y at t=0.5 (compound read)", at.y, 25);
  check("pos.x() at t=0.5 (axis read)", pos.x(), 50);
  check("pos.y() at t=0.5 (axis read)", pos.y(), 25);
}

// One axis animated independently of its sibling.
{
  const mgfx = new Runtime();
  const pos = vec2Signal(mgfx, "pos", { x: 0, y: 10 });
  mgfx.compile(pos.x(100, 1.0));

  mgfx.sampleAt(0.5);
  check("pos.x() at t=0.5 (single axis)", pos.x(), 50);
  check("pos.y() unchanged (single axis)", pos.y(), 10);
}

// Reading a signal before compile() throws
{
  const mgfx = new Runtime();
  const x = signal(mgfx, "x", 0);
  let threw = false;
  try {
    x();
  } catch {
    threw = true;
  }
  console.log(`${threw ? "ok " : "FAIL"} reading a signal before compile() throws`);
  if (!threw) failures++;
}

console.log(failures === 0 ? "\nAll checks passed." : `\n${failures} check(s) FAILED.`);
if (failures > 0) Deno.exit(1);
