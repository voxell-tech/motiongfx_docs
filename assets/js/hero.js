// The landing page hero: one MotionGfx timeline, played full screen.
// Bars ripple in from the centre, rise, roll a wave across, and ripple
// back out, each step a combinator (`flow`, `all`, `chain`) on the real
// wasm runtime. The lane under it draws those same steps as blocks, and
// dragging it scrubs the timeline, forward or back.
//
// Loaded by the kit's demo-bootstrap.js through the hero's
// `data-demo-src`, once per page load; `mountAll` runs again on each
// `tola:navigate` and picks up a fresh hero when the page comes back.
import { Ease, Runtime, all, chain, flow, ready, signal } from "/js/mgfx-demo.js";

const N = 28;

// Each bar's height once risen, as a share of the tallest a bar can
// be: two slow waves, so the row reads as a skyline, not noise.
const RISE = Array.from(
  { length: N },
  (_, c) =>
    0.22 +
    0.5 *
      (0.5 + 0.5 * Math.sin(c * 0.55)) *
      (0.55 + 0.45 * (0.5 + 0.5 * Math.cos(c * 1.7))),
);
const PEAK = RISE.map((h) => Math.min(1, h + 0.32));

// Bars paired from the centre out (13 and 14, then 12 and 15, ...).
const RINGS = Array.from({ length: N / 2 }, (_, k) => [
  N / 2 - 1 - k,
  N / 2 + k,
]);

// Each step's timing, in seconds. The lane's blocks are laid out from
// these, so they line up with what the runtime compiles.
const IN = { gap: 0.06, each: 0.5 };
const RISE_TIME = (c) => 0.7 + 0.3 * ((c * 7) % N) / N;
const WAVE = { gap: 0.05, up: 0.3, down: 0.45 };
const OUT = { gap: 0.05, each: 0.45 };

function steps() {
  const flowLength = (count, gap, each) => (count - 1) * gap + each;
  const lengths = [
    flowLength(RINGS.length, IN.gap, IN.each),
    Math.max(...RISE.map((_, c) => RISE_TIME(c))),
    flowLength(N, WAVE.gap, WAVE.up + WAVE.down),
    flowLength(RINGS.length, OUT.gap, OUT.each),
  ];
  const meta = [
    { op: "flow", name: "Ripple in" },
    { op: "all", name: "Rise" },
    { op: "flow + chain", name: "Wave" },
    { op: "flow", name: "Ripple out" },
  ];
  let start = 0;
  return meta.map((m, i) => {
    const step = { ...m, start, end: start + lengths[i] };
    start = step.end;
    return step;
  });
}

function build(mgfx) {
  const size = Array.from({ length: N }, (_, c) => signal(mgfx, `size${c}`, 0));
  const lift = Array.from({ length: N }, (_, c) => signal(mgfx, `lift${c}`, 0));

  const rippleIn = flow(
    IN.gap,
    RINGS.map((ring) =>
      all(ring.map((c) => size[c](1, IN.each, Ease.BackOut))),
    ),
  );
  const rise = all(
    RISE.map((h, c) => lift[c](h, RISE_TIME(c), Ease.CubicInOut)),
  );
  const wave = flow(
    WAVE.gap,
    lift.map((l, c) =>
      chain([
        l(PEAK[c], WAVE.up, Ease.SineOut),
        l(RISE[c], WAVE.down, Ease.SineInOut),
      ]),
    ),
  );
  const rippleOut = flow(
    OUT.gap,
    [...RINGS].reverse().map((ring) =>
      all(
        ring.flatMap((c) => [
          lift[c](0, OUT.each, Ease.CubicIn),
          size[c](0, OUT.each, Ease.BackIn),
        ]),
      ),
    ),
  );

  mgfx.compile(chain([rippleIn, rise, wave, rippleOut]));
  return { size, lift };
}

// Monokai Pro: low bars cyan, rising through purple to pink.
const STOPS = [
  [120, 220, 232],
  [171, 157, 242],
  [255, 97, 136],
];

function colourAt(t) {
  const x = Math.min(1, Math.max(0, t)) * (STOPS.length - 1);
  const i = Math.min(STOPS.length - 2, Math.floor(x));
  const f = x - i;
  const c = STOPS[i].map((v, n) => Math.round(v + (STOPS[i + 1][n] - v) * f));
  return `rgb(${c[0]}, ${c[1]}, ${c[2]})`;
}

function seconds(s) {
  return `${s.toFixed(2)}s`;
}

function mount(hero) {
  if (hero.dataset.mounted) return;
  hero.dataset.mounted = "true";

  const canvas = hero.querySelector(".mgfx-hero-canvas");
  const lane = hero.querySelector(".mgfx-lane");
  const button = hero.querySelector(".mgfx-lane-play");
  const time = hero.querySelector(".mgfx-lane-time");
  const ctx = canvas.getContext("2d");
  const reduced = window.matchMedia("(prefers-reduced-motion: reduce)");

  ready().then(() => {
    const mgfx = new Runtime();
    const { size, lift } = build(mgfx);
    const plan = steps();
    // The runtime's own length wins if the two ever disagree; the
    // blocks scale to it.
    const duration = mgfx.duration;
    const scale = duration / plan[plan.length - 1].end;

    // The lane: one block per step, and a playhead.
    const blocks = plan.map((step) => {
      const block = document.createElement("div");
      block.className = "mgfx-lane-block";
      block.style.left = `${((step.start * scale) / duration) * 100}%`;
      block.style.width = `${(((step.end - step.start) * scale) / duration) * 100}%`;
      const op = document.createElement("code");
      op.textContent = step.op;
      const name = document.createElement("span");
      name.textContent = step.name;
      block.append(op, name);
      lane.append(block);
      return { block, start: step.start * scale, end: step.end * scale };
    });
    const head = document.createElement("div");
    head.className = "mgfx-lane-head";
    lane.append(head);

    let width = 0;
    let height = 0;
    let t = 0;
    let playing = !reduced.matches;
    let visible = true;
    let frame = 0;
    let last = null;

    function resize() {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      width = canvas.clientWidth;
      height = canvas.clientHeight;
      canvas.width = Math.round(width * dpr);
      canvas.height = Math.round(height * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }

    function draw() {
      const light = document.documentElement.dataset.theme === "light";
      mgfx.sampleAt(t);
      ctx.clearRect(0, 0, width, height);

      const base = height * 0.8;
      const tallest = height * 0.5;
      const slot = width / N;
      const thick = Math.min(slot * 0.56, 46);

      // The floor the bars stand on.
      const floor = ctx.createLinearGradient(0, 0, width, 0);
      floor.addColorStop(0, "rgba(120, 220, 232, 0)");
      floor.addColorStop(0.5, light ? "rgba(98, 72, 200, 0.35)" : "rgba(171, 157, 242, 0.35)");
      floor.addColorStop(1, "rgba(255, 97, 136, 0)");
      ctx.fillStyle = floor;
      ctx.fillRect(0, base + 1, width, 1);

      for (let c = 0; c < N; c++) {
        const s = size[c]();
        if (s < 0.01) continue;
        const h = lift[c]();
        const w = thick * s;
        const tall = w + h * tallest;
        const x = slot * (c + 0.5) - w / 2;
        const top = base - tall;
        const colour = colourAt(h / 0.9);

        const fill = ctx.createLinearGradient(0, base, 0, top);
        fill.addColorStop(0, colourAt(0));
        fill.addColorStop(1, colour);
        ctx.fillStyle = fill;
        ctx.shadowColor = colour;
        ctx.shadowBlur = light ? 6 + 10 * h : 10 + 26 * h;
        ctx.beginPath();
        ctx.roundRect(x, top, w, tall, w / 2);
        ctx.fill();
        ctx.shadowBlur = 0;

        // A faint reflection on the floor.
        const mirror = ctx.createLinearGradient(0, base + 4, 0, base + 4 + tall * 0.6);
        mirror.addColorStop(0, light ? "rgba(98, 72, 200, 0.08)" : "rgba(171, 157, 242, 0.16)");
        mirror.addColorStop(1, "rgba(0, 0, 0, 0)");
        ctx.fillStyle = mirror;
        ctx.beginPath();
        ctx.roundRect(x, base + 4, w, tall * 0.6, [0, 0, w / 2, w / 2]);
        ctx.fill();
      }

      const progress = t / duration;
      head.style.left = `${progress * 100}%`;
      lane.setAttribute("aria-valuenow", t.toFixed(2));
      time.textContent = `${seconds(t)} / ${seconds(duration)}`;
      for (const b of blocks) {
        b.block.toggleAttribute("data-active", t >= b.start && t < b.end);
      }
    }

    function tick(now) {
      frame = 0;
      if (!hero.isConnected) return;
      // A frame's timestamp can come in under the one it was scheduled
      // at, so clamp, and skip the first frame's gap entirely.
      const dt = last === null ? 0 : Math.min(0.05, Math.max(0, (now - last) / 1000));
      last = now;
      t = (t + dt) % duration;
      draw();
      if (running()) frame = requestAnimationFrame(tick);
    }

    function running() {
      return playing && visible && !document.hidden;
    }

    // Starts the frame loop if it should be running and isn't. The
    // clock restarts with it, so a pause doesn't count as play time.
    function schedule() {
      if (frame || !running()) return;
      last = null;
      frame = requestAnimationFrame(tick);
    }

    function setPlaying(on) {
      playing = on;
      button.setAttribute("aria-label", on ? "Pause" : "Play");
      button.toggleAttribute("data-playing", on);
      if (on) schedule();
      else if (frame) {
        cancelAnimationFrame(frame);
        frame = 0;
      }
    }

    // Scrubbing: press anywhere on the lane and drag. Playback holds
    // while the pointer is down and picks up again on release.
    let resume = false;
    function seek(event) {
      const rect = lane.getBoundingClientRect();
      const x = Math.min(1, Math.max(0, (event.clientX - rect.left) / rect.width));
      t = Math.min(x * duration, duration - 0.0001);
      draw();
    }
    lane.addEventListener("pointerdown", (event) => {
      resume = playing;
      setPlaying(false);
      lane.setPointerCapture(event.pointerId);
      lane.toggleAttribute("data-scrubbing", true);
      seek(event);
    });
    lane.addEventListener("pointermove", (event) => {
      if (lane.hasPointerCapture(event.pointerId)) seek(event);
    });
    const release = () => {
      lane.toggleAttribute("data-scrubbing", false);
      if (resume) setPlaying(true);
    };
    lane.addEventListener("pointerup", release);
    lane.addEventListener("pointercancel", release);
    lane.addEventListener("keydown", (event) => {
      const step = { ArrowLeft: -0.1, ArrowRight: 0.1 }[event.key];
      if (step === undefined) return;
      event.preventDefault();
      setPlaying(false);
      t = Math.min(duration - 0.0001, Math.max(0, t + step));
      draw();
    });
    lane.setAttribute("aria-valuemax", duration.toFixed(2));

    button.addEventListener("click", () => setPlaying(!playing));

    new IntersectionObserver((entries) => {
      visible = entries.some((e) => e.isIntersecting);
      schedule();
    }).observe(hero);
    document.addEventListener("visibilitychange", schedule);
    new MutationObserver(draw).observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"],
    });
    new ResizeObserver(() => {
      resize();
      draw();
    }).observe(canvas);

    // Reduced motion: a still frame with every bar standing.
    if (reduced.matches) t = plan[1].end * scale;
    resize();
    setPlaying(playing);
    draw();
  });
}

function mountAll() {
  document.querySelectorAll(".mgfx-hero").forEach(mount);
}

mountAll();
document.addEventListener("tola:navigate", mountAll);
