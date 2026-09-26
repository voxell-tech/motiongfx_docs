#import "/templates/docs.typ": docs-page

#show: docs-page.with(title: "Bevy MotionGfx")

= Bevy MotionGfx

This page assumes a working Bevy project already exists. If you don't
have one yet, stop here and go set one up first:
#link("https://bevy.org/learn/quick-start/getting-started/setup/")[Bevy's own Quick Start guide]
walks through installing Rust and creating a new Bevy project from
scratch. Once `cargo run` opens an empty window for you, come back here.

== Add the plugin

```bash
cargo add bevy_motiongfx
```

```rust
use bevy::prelude::*;
use bevy_motiongfx::BevyMotionGfxPlugin;
use bevy_motiongfx::prelude::*;

fn main() {
    App::new()
        .add_plugins((DefaultPlugins, BevyMotionGfxPlugin))
        .add_systems(Startup, (setup, build_timeline))
        .run();
}
```

`BevyMotionGfxPlugin` adds a `MotionGfxManager` resource. That's the
only setup it needs: `motiongfx.create_builder()` gives you a builder
that already knows how to animate any Bevy entity's components.

== Set up a scene

```rust
fn setup(mut commands: Commands) {
    commands.spawn((Camera3d::default(), Transform::from_xyz(0.0, 0.0, 15.0)));
    commands.spawn((
        DirectionalLight::default(),
        Transform::from_xyz(3.0, 10.0, 5.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
}
```

== Give it something to animate

```rust
fn build_timeline(
    mut commands: Commands,
    mut motiongfx: ResMut<MotionGfxManager>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    let material = materials.add(StandardMaterial::from_color(Srgba::BLUE));
    let cube = commands
        .spawn((
            Mesh3d(meshes.add(Cuboid::default())),
            MeshMaterial3d(material.clone()),
            Transform::from_xyz(-3.0, 0.0, 0.0),
        ))
        .id();
    // ...
}
```

`cube` and `material` are the two subjects you'll animate next. Both are
ids, which is how every backend addresses a subject.

== Describe the animation

Continuing inside the same `build_timeline` function:

```rust
    let mut b = motiongfx.create_builder();
    let track = [
        b.act(cube, path!(<Transform>::translation::x), |x| x + 6.0).play(s(1)),
        b.act(material.id().untyped(), path!(<StandardMaterial>::base_color), |_| {
            Srgba::RED.into()
        })
        .play(s(1)),
    ]
    .ord_all()
    .compile();

    let timeline = b.compile(track);
    commands.spawn((motiongfx.add_timeline(timeline), RealtimePlayer::new().with_playing(true)));
}
```

`motiongfx.create_builder()` gives you the same `b` the rest of these
docs talk about. See #link("/docs/concepts/actions")[Actions] for what
`.act()`'s three arguments mean, #link("/docs/concepts/ordering")[Ordering]
for combinators like `.ord_all()`, and
#link("/docs/concepts/timeline")[Timeline] for what `.compile()` and
`b.compile()` actually produce.

`RealtimePlayer` samples the timeline every frame and writes the
results back onto your entities. Once it's spawned, there's nothing else
to call.

== Run it

```bash
cargo run
```

A blue cube slides right and turns red over one second.
