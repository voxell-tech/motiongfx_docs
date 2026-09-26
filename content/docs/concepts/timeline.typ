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

You can call this with any time in the track's range, in any order:
forward, backward, or the same instant twice.

== Two-way playback

Sampling only ever reads two already-baked values and interpolates
between them. Nothing gets replayed, so moving backward costs exactly the
same as moving forward.

In the demo below, six circles fly in on a stagger, growing and changing
color, then a bounce ripples through the row. All of it is one baked
`Track`, sampled at whatever time the scrubber asks for.

#ui.live-demo(
  id: "timeline-showcase-demo",
  script: "/js/demos/timeline-showcase.js",
  caption: [Flow in, then a bounce ripples through the row, flashing color as it goes.],
)
