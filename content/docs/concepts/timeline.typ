#import "/templates/docs.typ": docs-page
#import "/components/ui.typ" as ui

#show: docs-page.with(title: "Timeline")

= Timeline

Once your fragments are ordered the way you want, `.compile()` freezes the
result into a `Track`.

```rust
let track = fragment.compile();
```

== Building the timeline

The builder turns one or more tracks into a `Timeline`.

```rust
let mut timeline = b.compile(track);
```

== Baking

Before it can be sampled, a timeline is baked once. This runs every
action's closure exactly one time and records its start and end values.

```rust
timeline.bake_actions(&registry, &world);
```

== Sampling

Move the playhead, then write the values back into your world.

```rust
timeline.set_target_time(cs(50));
timeline.queue_actions();
timeline.sample_queued_actions(&registry, &mut world);
```

Call this with any time in the track's range, in any order. Forward,
backward, the exact same instant twice, it always works.

== Two-way playback

Sampling only ever reads two already-baked values and interpolates
between them. Nothing gets replayed, so moving backward costs exactly the
same as moving forward.

Six circles fly in staggered, growing and recoloring together, then a
bounce ripples through the row once they've landed, flashing back toward
cyan as each one grows. All of it, forward or backward, is the same baked
`Track`, sampled at whatever time you ask for. Drag the scrubber, jump
around, run it backward: nothing gets re-simulated.

#ui.live-demo(
  id: "timeline-showcase-demo",
  script: "/js/demos/timeline-showcase.js",
  caption: [Flow in, then a bounce ripples through the row, flashing color as it goes.],
)

== Next

#link("/docs/advanced")[Building a Backend] covers what `registry` and
`world` actually are.
