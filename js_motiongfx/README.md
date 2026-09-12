# js_motiongfx

MotionGfx, compiled to wasm, with a JS/TS-native API on top: real signals
(call a signal to read it, call it with a value and a duration to
animate it), the same five ordering combinators as the Rust crate, and
the same two-way playback guarantee (bake once, scrub forward or
backward for free).

```ts
import { all, Ease, Runtime, signal } from "./js/runtime.ts";

const mgfx = new Runtime();
const radius = signal(mgfx, "radius", 20);
const mix = signal(mgfx, "mix", 0);

mgfx.compile(all([radius(70, 1.0), mix(1.0, 1.0, Ease.CubicInOut)]));

mgfx.sampleAt(0.5);
console.log(radius(), mix()); // 45, 0.5 (or eased, for mix)
```

## Why this isn't just `motiongfx` with a JS accent

`TimelineBuilder` borrows its `Registry` for as long as it's alive, and
every action builder derived from it borrows the `TimelineBuilder` in
turn. That's fine in native Rust, where `.act(...).play(...)` all
happens in one expression. It doesn't survive being split across
separate JS to wasm calls: there's no way to hand JS a live,
still-borrowed Rust builder to call `.act()` on again later without
`unsafe` or interior mutability, which the project avoids reaching for
unless it's actually necessary.

`act`, `chain`, `all`, `any`, `flow`, and `delay` (`src/lib.rs`) are real
wasm functions, not JS reimplementations: they build a `Fragment`, an
unresolved description, and none of them touch the registry or builder
at all. Only `Runtime::compile` does: it's the one call that resolves
the whole `Fragment` tree against a single builder, playing, ordering,
compiling, and baking within that call. The borrow never has to cross
the boundary.

`Runtime` itself (id/name bookkeeping, the compiled timeline, sampling)
is Rust too, all plain ownership, since none of that touches the
registry. `js/runtime.ts` adds exactly the one thing Rust can't express:
`signal()`, a function that's also an object (Motion Canvas's signal
trick), so calling it with no arguments reads a value and calling it
with a target and a duration describes an animation. Everything else in
that file is a re-export.

One consequence: every subject is a plain `f64` (`src/lib.rs`'s
`JsWorld`). There's no equivalent of `path!(<Type>::field)` reaching
into a real struct, since a JS object has no compile-time shape for Rust
to walk. Structured values (a vector, a color) are one signal per
component, combined on the JS side. `vec2Signal` in `js/runtime.ts` is a
worked example: a compound signal (`pos()`, `pos({x, y}, dur)`) built
from two `Signal`s attached as `pos.x`/`pos.y`, matching Motion Canvas's
`transform.position.x(...)` shape.

Action closures (`radius((x) => x + 50, 1.0)`) are a second wrinkle:
`Action<T>` requires `Send + Sync`, which a captured `js_sys::Function`
is not, since JS values are single-threaded. `SendWrapper` (see
`src/lib.rs`) asserts that's fine here, since a normal wasm32 build (no
`atomics` target feature) only ever runs on one thread, and panics
instead of silently allowing real unsoundness if that's ever actually
violated.

## Building

```sh
# The Rust core, targeting whatever consumes it:
wasm-pack build --target web --out-dir pkg      # browsers, <script type="module">
wasm-pack build --target bundler --out-dir pkg  # webpack/vite/etc.
wasm-pack build --target deno --out-dir pkg     # Deno (used by the test suite below)
```

`js/runtime.ts` imports from `../pkg/js_motiongfx.js`, so build into
`pkg/` before using it.

## Testing

`js/test.ts` is a real, executed end-to-end test, not just a
read-through: signals, literal and function transforms, easing, every
ordering combinator, two-way playback (sampling backward off the same
bake), and the error path for reading a signal before compiling.

```sh
wasm-pack build --target deno --out-dir pkg --out-name js_motiongfx
cd js && deno run --allow-read --allow-net test.ts
```

## API

- `new Runtime()`: a scope for signals and the timeline compiled from them.
- `signal(runtime, name, initial)`: creates a subject on `runtime`, returns its `Signal`.
  - `signal()` reads the current value (only valid after `compile()` and a `sampleAt()`).
  - `signal(to, durationSecs, ease?)` returns a `Fragment` animating it. `to` is
    a target value or `(current: number) => number`.
- `chain(fragments)` / `all(fragments)` / `any(fragments)`: combine fragments.
- `flow(delaySecs, fragments)` / `delay(delaySecs, fragment)`: timing-only combinators.
- `runtime.compile(fragment)`: resolves, orders, compiles, and bakes.
- `runtime.duration`: the compiled track's length, in seconds.
- `runtime.sampleAt(seconds)`: moves the playhead and samples. Forward, backward,
  or the same instant twice, cost the same.

`Ease` is a real exported enum (`Ease.Linear`, `Ease.CubicInOut`, ...),
matching `motiongfx::prelude::ease`: `Linear`, and
`{Sine,Quad,Cubic,Quart,Quint,Expo,Circ,Back,Elastic}` each with
`In`/`Out`/`InOut` suffixes.

## What's not here yet

This is the runtime and its API, verified correct end-to-end, but not a
publish pipeline. Still open: an actual `npm publish` step in CI
(parallel to the existing crates.io release), and `package.json`
pointing at compiled JS rather than raw `.ts` (needs a `tsc`/bundler
step, since npm can't assume every consumer runs TypeScript directly
the way Deno does).
