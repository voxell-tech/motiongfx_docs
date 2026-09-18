//! Demo: "Scrub Forward and Backward, for Free" (see the landing page).
//! The Rust snippet shown on the docs site is read straight out of the
//! `snippet:start`/`snippet:end` region below; see relative.rs for why.

use core::time::Duration;

use motiongfx::prelude::*;
use wasm_bindgen::prelude::*;

use super::shape::{self, Shape};

const X: f64 = 340.0;
const RADIUS: f64 = 18.0;

struct Ball {
    y: f64,
}

struct BallWorld(Ball);

impl SubjectSource<(), Ball> for BallWorld {
    fn get_source(&self, _id: ()) -> Option<&Ball> {
        Some(&self.0)
    }

    fn apply_source<R>(
        &mut self,
        _id: (),
        f: impl FnOnce(&mut Ball) -> R,
    ) -> Option<R> {
        Some(f(&mut self.0))
    }
}

#[wasm_bindgen]
pub struct BounceDemo {
    registry: Registry,
    world: BallWorld,
    timeline: Timeline<BallWorld>,
}

#[wasm_bindgen]
impl BounceDemo {
    #[wasm_bindgen(constructor)]
    pub fn new() -> BounceDemo {
        let ball = ();
        let world = BallWorld(Ball { y: 140.0 });
        let mut registry = Registry::new();
        let mut b = registry.create_builder::<BallWorld>();

        // snippet:start
        let track = [
            b.act(ball, path!(<Ball>::y), |_| 30.0)
                .with_ease(ease::quad::ease_out)
                .play(ms(600)),
            b.act(ball, path!(<Ball>::y), |_| 140.0)
                .with_ease(ease::quad::ease_in)
                .play(ms(600)),
        ]
        .ord_chain()
        .compile();
        // snippet:end

        let mut timeline = b.compile(track);
        timeline.bake_actions(&registry, &world);

        BounceDemo {
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

    /// Every shape this demo draws, flattened for `mgfx-demo.js`'s
    /// generic renderer; see `shape.rs`.
    pub fn shapes(&self) -> Vec<f64> {
        shape::flatten([Shape::Circle(shape::Circle {
            x: X,
            y: self.world.0.y,
            radius: RADIUS,
        })])
    }
}

impl Default for BounceDemo {
    fn default() -> Self {
        Self::new()
    }
}
