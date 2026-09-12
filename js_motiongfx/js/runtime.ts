// Thin JS/TS layer over the raw wasm bindings in `../pkg`. `Runtime`,
// `act`, `chain`, `all`, `any`, `flow`, and `delay` there are the real
// Rust implementation; `signal()` below is the one thing Rust can't
// express, a function that's also an object (Motion Canvas's signal
// trick), so it's the only piece that has to live here.
import { act, all, Ease, Fragment, Runtime } from "../pkg/js_motiongfx.js";

export { act, all, any, chain, delay, Ease, flow, Fragment, Runtime } from "../pkg/js_motiongfx.js";

/** A target value, or a function of the subject's current value. */
export type Transform = number | ((current: number) => number);

/**
 * A signal. Call with no arguments to read its current value (valid
 * once `runtime.compile()` has sampled). Call with a target value (or a
 * function of the current value) and a duration in seconds to describe
 * an animation of it, returned as a `Fragment` for `runtime.compile()`.
 */
export interface Signal {
  (): number;
  (to: Transform, durationSecs: number, ease?: Ease): Fragment;
  readonly name: string;
}

/** Creates a named signal on `runtime` and returns it. */
export function signal(runtime: Runtime, name: string, initial: number): Signal {
  const id = runtime.createSignal(name, initial);

  const fn = ((to?: Transform, durationSecs?: number, ease?: Ease) => {
    if (to === undefined) {
      return runtime.get(id);
    }
    if (durationSecs === undefined) {
      throw new Error(`signal "${name}": a duration is required when setting a value`);
    }
    return act(id, to, durationSecs, ease ?? null);
  }) as Signal;
  Object.defineProperty(fn, "name", { value: name });
  return fn;
}

/** A 2D value. */
export interface Vec2 {
  x: number;
  y: number;
}

/**
 * A compound signal over two `f64` subjects. Call with no arguments to
 * read both components. Call with a target `Vec2` and a duration in
 * seconds to animate both together (with the same easing), returned as
 * a `Fragment`. `.x`/`.y` are the two component `Signal`s, for reading
 * or animating one axis independently, the same way
 * `transform.position.x(...)` addresses one axis in Motion Canvas.
 *
 * There's no relative `(current: Vec2) => Vec2` overload: each axis
 * bakes independently, so a relative change only has one axis's current
 * value to work with. Use `.x(fn, durationSecs)` for that, per axis.
 */
export interface Vec2Signal {
  (): Vec2;
  (to: Vec2, durationSecs: number, ease?: Ease): Fragment;
  readonly x: Signal;
  readonly y: Signal;
  readonly name: string;
}

/** Creates a compound signal on `runtime` from two `f64` subjects, `name.x` and `name.y`. */
export function vec2Signal(runtime: Runtime, name: string, initial: Vec2): Vec2Signal {
  const x = signal(runtime, `${name}.x`, initial.x);
  const y = signal(runtime, `${name}.y`, initial.y);

  const fn = ((to?: Vec2, durationSecs?: number, ease?: Ease) => {
    if (to === undefined) {
      return { x: x(), y: y() };
    }
    if (durationSecs === undefined) {
      throw new Error(`signal "${name}": a duration is required when setting a value`);
    }
    return all([x(to.x, durationSecs, ease), y(to.y, durationSecs, ease)]);
  }) as Vec2Signal;
  Object.defineProperty(fn, "name", { value: name });
  Object.defineProperty(fn, "x", { value: x });
  Object.defineProperty(fn, "y", { value: y });
  return fn;
}
