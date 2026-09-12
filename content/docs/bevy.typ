#import "/templates/docs.typ": docs-page

#show: docs-page.with(title: "Bevy MotionGfx")

= Bevy MotionGfx

```
cargo add bevy bevy_motiongfx
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

fn setup(mut commands: Commands) {
    commands.spawn((Camera3d::default(), Transform::from_xyz(0.0, 0.0, 15.0)));
    commands.spawn((
        DirectionalLight::default(),
        Transform::from_xyz(3.0, 10.0, 5.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
}

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

```
cargo run
```

A blue cube slides right and turns red over one second.

`BevyMotionGfxPlugin` adds a `MotionGfxManager` resource. That's the only
setup it needs: `motiongfx.create_builder()` gives you a builder that
already knows how to animate any Bevy entity's components.

== Next

#link("/docs/concepts/actions")[Concepts]: what `act`, `play`, and
`compile` are actually doing.
