//! Demo: "Relative, Not Absolute" (see the landing page). The Rust
//! snippet shown on the docs site (content/index.typ) is read straight
//! out of the region marked `snippet:start`/`snippet:end` below, so
//! the code on the page can never drift from what's actually compiled
//! and running in the browser.

use core::ops::Add;
use core::time::Duration;

use motiongfx::prelude::*;
use wasm_bindgen::prelude::*;

use super::shape::{self, Shape};

const RADIUS: f64 = 16.0;

#[derive(Clone, Copy)]
struct Vec2 {
    x: f64,
    y: f64,
}

impl Add for Vec2 {
    type Output = Vec2;

    fn add(self, rhs: Vec2) -> Vec2 {
        Vec2 {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

// Interpolating a `Vec2` field means interpolating each component;
// motiongfx only knows how to do that itself for the primitives it
// ships (`f64` among them), so a compound type spells it out once
// here instead of reaching for `act_builder().with_interp(...)` at
// every call site.
impl Interpolation<()> for Vec2 {
    fn interp(a: &Self, b: &Self, t: f32) -> Self {
        Vec2 {
            x: f64::interp(&a.x, &b.x, t),
            y: f64::interp(&a.y, &b.y, t),
        }
    }
}

struct Dot {
    position: Vec2,
}

struct DotWorld(Dot);

impl SubjectSource<(), Dot> for DotWorld {
    fn get_source(&self, _id: ()) -> Option<&Dot> {
        Some(&self.0)
    }

    fn apply_source<R>(
        &mut self,
        _id: (),
        f: impl FnOnce(&mut Dot) -> R,
    ) -> Option<R> {
        Some(f(&mut self.0))
    }
}

#[wasm_bindgen]
pub struct RelativeDemo {
    registry: Registry,
    world: DotWorld,
    timeline: Timeline<DotWorld>,
}

#[wasm_bindgen]
impl RelativeDemo {
    #[wasm_bindgen(constructor)]
    pub fn new() -> RelativeDemo {
        let dot = ();
        let world = DotWorld(Dot {
            position: Vec2 { x: 60.0, y: 85.0 },
        });
        let mut registry = Registry::new();
        let mut b = registry.create_builder::<DotWorld>();

        // snippet:start
        let deltas = [
            Vec2 { x: 180.0, y: 50.0 },
            Vec2 {
                x: 180.0,
                y: -100.0,
            },
            Vec2 { x: 180.0, y: 50.0 },
        ];
        let tracks = deltas.map(|delta| {
            b.act(dot, path!(<Dot>::position), move |p| *p + delta)
                .with_ease(ease::cubic::ease_in_out)
                .play(cs(50))
        });

        let track = tracks.ord_chain().compile();
        // snippet:end

        let mut timeline = b.compile(track);
        timeline.bake_actions(&registry, &world);

        RelativeDemo {
            registry,
            world,
            timeline,
        }
    }

    #[wasm_bindgen(getter)]
    pub fn duration(&self) -> f64 {
        self.timeline.tracks()[0].duration().as_secs_f64()
    }

    #[wasm_bindgen(js_name = sampleAt)]
    pub fn sample_at(&mut self, seconds: f64) {
        self.timeline.set_target_time(Duration::from_secs_f64(
            seconds.max(0.0),
        ));
        self.timeline.queue_actions();
        self.timeline
            .sample_queued_actions(&self.registry, &mut self.world);
    }

    /// Every shape this demo draws, flattened for
    /// `mgfx-demo.js`'s generic renderer; see
    /// `shape.rs`.
    pub fn shapes(&self) -> Vec<f64> {
        let position = self.world.0.position;
        shape::flatten([Shape::Circle(shape::Circle {
            x: position.x,
            y: position.y,
            radius: RADIUS,
        })])
    }
}

impl Default for RelativeDemo {
    fn default() -> Self {
        Self::new()
    }
}
