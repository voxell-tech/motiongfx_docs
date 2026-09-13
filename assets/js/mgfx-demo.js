// Shared harness for embedding a live motiongfx demo on any page. A
// demo supplies `build(mgfx) -> Fragment` (what to animate) and
// `draw(ctx, mgfx, canvas)` (how to paint one sampled frame); this file
// owns everything else: loading the wasm runtime once, a play/pause and
// scrub bar, autoplay that pauses when the tab isn't visible, honoring
// prefers-reduced-motion, and re-mounting after Tola's SPA router morphs
// a page in without re-executing scripts.
//
// `js_motiongfx` (see the motiongfx repo's `crates/js_motiongfx/`) only
// ever produces numbers; drawing them is entirely the caller's job, the
// same split Motion Canvas uses (a plain data engine plus a thin layer
// that calls the browser's native Canvas 2D API each frame).
import init, {
  act,
  all,
  any,
  chain,
  delay,
  Ease,
  flow,
  Runtime,
} from "/wasm/js_motiongfx.js";

export { act, all, any, chain, delay, Ease, flow, Runtime };

/** The `js/runtime.ts` signal wrapper, inlined: the site has no TS build step. */
export function signal(runtime, name, initial) {
  const id = runtime.createSignal(name, initial);
  return (to, durationSecs, ease) => {
    if (to === undefined) return runtime.get(id);
    return act(id, to, durationSecs, ease ?? null);
  };
}

/**
 * A compound signal over two `f64` subjects, `name.x` and `name.y` (the
 * `js/runtime.ts` `vec2Signal` wrapper, inlined for the same reason as
 * `signal` above). Call with no args to read both components; call with
 * a target `{x, y}` and a duration to animate both together with the
 * same easing, returned as a Fragment. `.x`/`.y` are the two per-axis
 * signals, for reading or animating one on its own.
 */
export function vec2Signal(runtime, name, initial) {
  const x = signal(runtime, `${name}.x`, initial.x);
  const y = signal(runtime, `${name}.y`, initial.y);

  const fn = (to, durationSecs, ease) => {
    if (to === undefined) return { x: x(), y: y() };
    return all([x(to.x, durationSecs, ease), y(to.y, durationSecs, ease)]);
  };
  fn.x = x;
  fn.y = y;
  return fn;
}

let wasmReady = null;

function loadWasm() {
  wasmReady ??= init();
  return wasmReady;
}

function formatSeconds(seconds) {
  return `${seconds.toFixed(2)}s`;
}

/**
 * Builds a single-row transport bar (play/pause, then the scrubber, then
 * a time readout), inserted right after `canvas`. Styling lives in
 * assets/styles/tailwind.css under `.mgfx-player-*`; see the comment
 * there for why it's not plain utility classes here.
 */
function createControls(canvas, duration) {
  const bar = document.createElement("div");
  bar.className = "mgfx-player-bar";

  const button = document.createElement("button");
  button.type = "button";
  button.className = "mgfx-player-button";

  const scrubber = document.createElement("input");
  scrubber.type = "range";
  scrubber.min = "0";
  scrubber.max = "1";
  scrubber.step = "0.001";
  scrubber.value = "0";
  scrubber.className = "mgfx-scrubber";
  scrubber.style.setProperty("--mgfx-progress", "0");
  scrubber.setAttribute("aria-label", "Scrub through the animation");

  const time = document.createElement("span");
  time.className = "mgfx-player-time";
  time.textContent = `${formatSeconds(0)} / ${formatSeconds(duration)}`;

  bar.append(button, scrubber, time);
  canvas.insertAdjacentElement("afterend", bar);

  // Inline SVGs, not glyphs: a Unicode play/pause symbol renders wildly
  // differently across fonts and OSes. `currentColor` picks up the
  // button's own text color, so hover/theme both just work.
  const playIcon = '<svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor"><path d="M4 2.5v11l10-5.5-10-5.5z"/></svg>';
  const pauseIcon = '<svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor"><rect x="3" y="2" width="4" height="12"/><rect x="9" y="2" width="4" height="12"/></svg>';

  const playPauseListeners = [];
  const scrubListeners = [];
  let playing = true;

  function setPlayingLabel(nowPlaying) {
    playing = nowPlaying;
    button.innerHTML = playing ? pauseIcon : playIcon;
    button.setAttribute("aria-label", playing ? "Pause" : "Play");
  }
  setPlayingLabel(true);

  button.addEventListener("click", () => {
    setPlayingLabel(!playing);
    for (const listener of playPauseListeners) listener(playing);
  });

  scrubber.addEventListener("input", () => {
    for (const listener of scrubListeners) listener(Number(scrubber.value));
  });

  return {
    onPlayPause: (listener) => playPauseListeners.push(listener),
    onScrub: (listener) => scrubListeners.push(listener),
    setPlaying: setPlayingLabel,
    setProgress(t) {
      // Don't fight the user's own drag mid-gesture.
      if (document.activeElement !== scrubber) scrubber.value = String(t);
      scrubber.style.setProperty("--mgfx-progress", String(t));
      time.textContent = `${formatSeconds(t * duration)} / ${formatSeconds(duration)}`;
    },
  };
}

// Wall-clock ms for one full ping-pong cycle (there and back), per
// second of the demo's own compiled duration. Deriving `periodMs` from
// `duration` instead of hand-tuning it per demo keeps playback speed
// comparable across demos: a 2s sequence visibly takes twice as long to
// play as a 1s one, matching what the timing diagrams beside them show.
const PERIOD_MS_PER_SECOND = 1700;

function mountOne(canvas, { build, draw, periodMs }) {
  if (canvas.dataset.mgfxMounted) return;
  canvas.dataset.mgfxMounted = "true";

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  loadWasm()
    .then(() => {
      const mgfx = new Runtime();
      mgfx.compile(build(mgfx));
      const duration = mgfx.duration;
      periodMs ??= Math.max(duration * PERIOD_MS_PER_SECOND, 400);

      const ctx = canvas.getContext("2d");

      // The canvas's pixel buffer defaults to the same size as its CSS
      // display size, so on any HiDPI screen it gets upscaled and looks
      // soft. Give it a buffer sized for the real device pixel ratio,
      // then scale the context so draw calls can keep using logical
      // (CSS-pixel) coordinates.
      const dpr = window.devicePixelRatio || 1;
      const logicalWidth = canvas.width;
      const logicalHeight = canvas.height;
      if (dpr !== 1) {
        canvas.width = logicalWidth * dpr;
        canvas.height = logicalHeight * dpr;
        ctx.scale(dpr, dpr);
      }

      const controls = createControls(canvas, duration);

      // `t` is normalized 0..1 over the whole compiled duration, not
      // seconds: demos compile to whatever duration their fragments add
      // up to, not always 1 second. Ping-ponging it demonstrates
      // two-way playback: every frame re-samples the same baked
      // timeline, forward and backward, with no re-simulation.
      let t = 0;
      let direction = 1;
      let userPaused = false;
      let lastFrameTime = null;
      let scheduled = false;

      function paint() {
        mgfx.sampleAt(t * duration);
        ctx.clearRect(0, 0, logicalWidth, logicalHeight);
        draw(ctx, mgfx, canvas);
        controls.setProgress(t);
      }

      function isRunning() {
        return !userPaused && !document.hidden && canvas.isConnected;
      }

      function frame(now) {
        if (!isRunning()) {
          scheduled = false;
          lastFrameTime = null;
          return;
        }

        if (lastFrameTime !== null) {
          const elapsedMs = now - lastFrameTime;
          const speed = 2 / periodMs; // one leg (0->1 or 1->0) takes periodMs/2
          t += direction * elapsedMs * speed;
          if (t >= 1) {
            t = 1;
            direction = -1;
          } else if (t <= 0) {
            t = 0;
            direction = 1;
          }
        }
        lastFrameTime = now;
        paint();

        requestAnimationFrame(frame);
      }

      function scheduleIfNeeded() {
        if (scheduled || !isRunning()) return;
        scheduled = true;
        lastFrameTime = null;
        requestAnimationFrame(frame);
      }

      controls.onPlayPause((playing) => {
        userPaused = !playing;
        if (playing) scheduleIfNeeded();
      });

      controls.onScrub((value) => {
        userPaused = true;
        controls.setPlaying(false);
        t = value;
        paint();
      });

      document.addEventListener("visibilitychange", scheduleIfNeeded);

      if (reduceMotion.matches) {
        // Show the settled end state instead of autoplaying.
        userPaused = true;
        controls.setPlaying(false);
        t = 1;
        paint();
        return;
      }

      paint();
      scheduleIfNeeded();
    })
    .catch((err) => {
      console.error("motiongfx demo failed to start:", err);
      const fallback = document.createElement("p");
      fallback.textContent = "Live demo failed to load. See console.";
      fallback.className = "text-subtle text-xs";
      canvas.replaceWith(fallback);
    });
}

/**
 * Mounts a demo onto every canvas matching `selector`, now and after any
 * future Tola SPA navigation. `build`/`draw` are as described above;
 * `periodMs` controls the full ping-pong cycle's duration (default 2200ms).
 */
export function mountDemo(selector, options) {
  function tryMount() {
    document.querySelectorAll(selector).forEach((canvas) => mountOne(canvas, options));
  }
  tryMount();
  document.addEventListener("tola:navigate", tryMount);
}
