//! Demo: "It's Just Code" (see the landing page). The Rust snippet shown
//! on the docs site is read straight out of the `snippet:start`/
//! `snippet:end` region below; see relative.rs for why.

use core::time::Duration;

use motiongfx::prelude::*;
use wasm_bindgen::prelude::*;

use super::shape::{self, Shape};

const BAR_WIDTH: f64 = 32.0;

struct Bar {
    x: f64,
    height: f64,
    y: f64,
}

struct BarsWorld {
    bars: Vec<Bar>,
}

impl SubjectSource<usize, Bar> for BarsWorld {
    fn get_source(&self, id: usize) -> Option<&Bar> {
        self.bars.get(id)
    }

    fn apply_source<R>(
        &mut self,
        id: usize,
        f: impl FnOnce(&mut Bar) -> R,
    ) -> Option<R> {
        self.bars.get_mut(id).map(f)
    }
}

#[wasm_bindgen]
pub struct BarsDemo {
    registry: Registry,
    world: BarsWorld,
    timeline: Timeline<BarsWorld>,
}

#[wasm_bindgen]
impl BarsDemo {
    #[wasm_bindgen(constructor)]
    pub fn new() -> BarsDemo {
        // The "data": how tall each bar grows to. Ordinary numbers, no
        // special authoring tool needed to place them.
        const HEIGHTS: [f64; 10] = [
            60.0, 110.0, 40.0, 130.0, 80.0, 150.0, 100.0, 55.0,
            120.0, 70.0,
        ];
        const BASELINE: f64 = 160.0;

        let count = HEIGHTS.len();
        let world = BarsWorld {
            bars: (0..count)
                .map(|i| Bar {
                    x: 40.0 + (600.0 / (count - 1) as f64) * i as f64,
                    height: 6.0,
                    y: BASELINE,
                })
                .collect(),
        };
        let mut registry = Registry::new();
        let mut b = registry.create_builder::<BarsWorld>();

        // snippet:start
        let stagger = ms(60);
        let tracks = HEIGHTS
            .iter()
            .enumerate()
            .map(|(i, &height)| {
                [
                    b.act(i, path!(<Bar>::height), move |_| height)
                        .with_ease(ease::cubic::ease_in_out)
                        .play(ms(600)),
                    b.act(i, path!(<Bar>::y), move |_| {
                        BASELINE - height / 2.0
                    })
                    .with_ease(ease::cubic::ease_in_out)
                    .play(ms(600)),
                ]
                .ord_all()
            })
            .collect::<Vec<_>>();

        let track = tracks.ord_flow(stagger).compile();
        // snippet:end

        let mut timeline = b.compile(track);
        timeline.bake_actions(&registry, &world);

        BarsDemo {
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
        shape::flatten(self.world.bars.iter().map(|bar| {
            Shape::Rect(shape::Rect {
                x: bar.x,
                y: bar.y,
                width: BAR_WIDTH,
                height: bar.height,
            })
        }))
    }
}

impl Default for BarsDemo {
    fn default() -> Self {
        Self::new()
    }
}
