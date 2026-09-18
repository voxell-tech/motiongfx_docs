//! MotionGfx runtime for JavaScript/TypeScript.
//!
//! Every subject is a plain `f64`, addressed by an integer id
//! ([`Runtime::create_signal`] hands out the names). `TimelineBuilder`
//! borrows its `Registry` for as long as it lives, and a `TrackFragment`'s
//! clips only resolve inside the specific builder that created them, so
//! a JS caller can't build actions across separate calls the way native
//! Rust does. `act`, `chain`, `all`, `any`, `flow`, and `delay` instead
//! build a [`Fragment`], an unresolved description, with zero registry
//! access; [`Runtime::compile`] is the one call that resolves the whole
//! tree against a single builder, plays it, orders it, compiles it, and
//! bakes it.

use core::time::Duration;

use js_sys::Function;
use motiongfx::prelude::*;
use motiongfx::track;
use send_wrapper::SendWrapper;
use wasm_bindgen::JsCast;
use wasm_bindgen::prelude::*;

/// Landing-page demos: each is a small self-contained scene written in
/// real motiongfx Rust and compiled straight into this crate, not
/// authored through the generic `act`/`chain`/... JS-facing API below.
/// The docs site reads each demo's own source file to show the
/// matching snippet, so page and code can't drift apart. See
/// `demos/relative.rs` for the pattern.
mod demos;
pub use demos::{BarsDemo, BounceDemo, RelativeDemo};

/// A subject's id inside a [`JsWorld`].
type Id = u32;

/// Every animatable value a JS caller creates: a flat, indexable list of
/// `f64`s. Field-level structure (what a subject "means") lives entirely
/// on the JS side.
struct JsWorld {
    values: Vec<f64>,
}

impl SubjectSource<Id, f64> for JsWorld {
    fn get_source(&self, id: Id) -> Option<&f64> {
        self.values.get(id as usize)
    }

    fn apply_source<R>(
        &mut self,
        id: Id,
        f: impl FnOnce(&mut f64) -> R,
    ) -> Option<R> {
        self.values.get_mut(id as usize).map(f)
    }
}

/// Easing curve, matching `motiongfx::prelude::ease`.
#[wasm_bindgen]
#[derive(Clone, Copy)]
pub enum Ease {
    Linear,
    SineIn,
    SineOut,
    SineInOut,
    QuadIn,
    QuadOut,
    QuadInOut,
    CubicIn,
    CubicOut,
    CubicInOut,
    QuartIn,
    QuartOut,
    QuartInOut,
    QuintIn,
    QuintOut,
    QuintInOut,
    ExpoIn,
    ExpoOut,
    ExpoInOut,
    CircIn,
    CircOut,
    CircInOut,
    BackIn,
    BackOut,
    BackInOut,
    ElasticIn,
    ElasticOut,
    ElasticInOut,
}

impl Ease {
    fn to_fn(self) -> EaseFn {
        use ease::*;
        match self {
            Ease::Linear => linear,
            Ease::SineIn => sine::ease_in,
            Ease::SineOut => sine::ease_out,
            Ease::SineInOut => sine::ease_in_out,
            Ease::QuadIn => quad::ease_in,
            Ease::QuadOut => quad::ease_out,
            Ease::QuadInOut => quad::ease_in_out,
            Ease::CubicIn => cubic::ease_in,
            Ease::CubicOut => cubic::ease_out,
            Ease::CubicInOut => cubic::ease_in_out,
            Ease::QuartIn => quart::ease_in,
            Ease::QuartOut => quart::ease_out,
            Ease::QuartInOut => quart::ease_in_out,
            Ease::QuintIn => quint::ease_in,
            Ease::QuintOut => quint::ease_out,
            Ease::QuintInOut => quint::ease_in_out,
            Ease::ExpoIn => expo::ease_in,
            Ease::ExpoOut => expo::ease_out,
            Ease::ExpoInOut => expo::ease_in_out,
            Ease::CircIn => circ::ease_in,
            Ease::CircOut => circ::ease_out,
            Ease::CircInOut => circ::ease_in_out,
            Ease::BackIn => back::ease_in,
            Ease::BackOut => back::ease_out,
            Ease::BackInOut => back::ease_in_out,
            Ease::ElasticIn => elastic::ease_in,
            Ease::ElasticOut => elastic::ease_out,
            Ease::ElasticInOut => elastic::ease_in_out,
        }
    }
}

/// An action or combinator not yet resolved into a `TrackFragment`. Build
/// one with [`act`], [`chain`], [`all`], [`any`], [`flow`], or [`delay`],
/// and hand the root to [`compile`].
#[wasm_bindgen]
pub struct Fragment(FragmentNode);

enum FragmentNode {
    Action {
        id: Id,
        to: SendWrapper<JsValue>,
        duration_secs: f64,
        ease: Option<Ease>,
    },
    Chain(Vec<FragmentNode>),
    All(Vec<FragmentNode>),
    Any(Vec<FragmentNode>),
    Flow(f64, Vec<FragmentNode>),
    Delay(f64, Box<FragmentNode>),
}

fn into_nodes(fragments: Vec<Fragment>) -> Vec<FragmentNode> {
    fragments.into_iter().map(|f| f.0).collect()
}

fn err(msg: impl core::fmt::Display) -> JsValue {
    JsValue::from_str(&msg.to_string())
}

/// Describes animating subject `id` to `to` (a target value, or a
/// function of its current value) over `duration_secs`.
#[wasm_bindgen]
pub fn act(
    id: Id,
    to: JsValue,
    duration_secs: f64,
    ease: Option<Ease>,
) -> Fragment {
    Fragment(FragmentNode::Action {
        id,
        to: SendWrapper::new(to),
        duration_secs,
        ease,
    })
}

/// Runs fragments one after another; the next starts when the previous finishes.
#[wasm_bindgen]
pub fn chain(fragments: Vec<Fragment>) -> Fragment {
    Fragment(FragmentNode::Chain(into_nodes(fragments)))
}

/// Runs fragments together; finishes when the slowest one does.
#[wasm_bindgen]
pub fn all(fragments: Vec<Fragment>) -> Fragment {
    Fragment(FragmentNode::All(into_nodes(fragments)))
}

/// Runs fragments together; finishes as soon as the fastest one does.
#[wasm_bindgen]
pub fn any(fragments: Vec<Fragment>) -> Fragment {
    Fragment(FragmentNode::Any(into_nodes(fragments)))
}

/// Like `chain`, but each fragment starts a fixed delay after the previous one starts.
#[wasm_bindgen]
pub fn flow(delay_secs: f64, fragments: Vec<Fragment>) -> Fragment {
    Fragment(FragmentNode::Flow(delay_secs, into_nodes(fragments)))
}

/// Pushes a single fragment's start later.
#[wasm_bindgen]
pub fn delay(delay_secs: f64, fragment: Fragment) -> Fragment {
    Fragment(FragmentNode::Delay(delay_secs, Box::new(fragment.0)))
}

/// Resolves one [`FragmentNode`] into a real [`TrackFragment`] against
/// `b`. The only step that touches the builder at all is the `Action`
/// leaf; every combinator just merges already-resolved fragments.
fn resolve(
    b: &mut TimelineBuilder<'_, JsWorld>,
    node: FragmentNode,
) -> TrackFragment {
    match node {
        FragmentNode::Action {
            id,
            to,
            duration_secs,
            ease,
        } => {
            let action = move |current: &f64| -> f64 {
                if let Some(func) = to.dyn_ref::<Function>() {
                    func.call1(
                        &JsValue::NULL,
                        &JsValue::from_f64(*current),
                    )
                    .ok()
                    .and_then(|v| v.as_f64())
                    .unwrap_or(*current)
                } else {
                    to.as_f64().unwrap_or(*current)
                }
            };
            let interp = b.act(id, path!(<f64>), action);
            let interp = match ease {
                Some(ease) => interp.with_ease(ease.to_fn()),
                None => interp,
            };
            interp
                .play(Duration::from_secs_f64(duration_secs.max(0.0)))
        }
        FragmentNode::Chain(children) => {
            track::chain(children.into_iter().map(|c| resolve(b, c)))
        }
        FragmentNode::All(children) => {
            track::all(children.into_iter().map(|c| resolve(b, c)))
        }
        FragmentNode::Any(children) => {
            track::any(children.into_iter().map(|c| resolve(b, c)))
        }
        FragmentNode::Flow(delay_secs, children) => track::flow(
            Duration::from_secs_f64(delay_secs.max(0.0)),
            children.into_iter().map(|c| resolve(b, c)),
        ),
        FragmentNode::Delay(delay_secs, child) => track::delay(
            Duration::from_secs_f64(delay_secs.max(0.0)),
            resolve(b, *child),
        ),
    }
}

/// A compiled, baked timeline: the id-to-value store it animates plus
/// enough of the registry to keep sampling it. `Runtime` owns one of
/// these internally; nothing outside this crate needs to name the type.
struct TimelineHandle {
    registry: Registry,
    timeline: Timeline<JsWorld>,
    world: JsWorld,
}

impl TimelineHandle {
    fn duration(&self) -> f64 {
        self.timeline.tracks()[0].duration().as_secs_f64()
    }

    /// Moves the playhead and samples.
    fn sample_at(&mut self, seconds: f64) {
        self.timeline.set_target_time(Duration::from_secs_f64(
            seconds.max(0.0),
        ));
        self.timeline.queue_actions();
        self.timeline
            .sample_queued_actions(&self.registry, &mut self.world);
    }

    fn get(&self, id: Id) -> f64 {
        self.world
            .values
            .get(id as usize)
            .copied()
            .unwrap_or(f64::NAN)
    }
}

/// Resolves, plays, orders, and compiles a [`Fragment`] tree into a
/// [`TimelineHandle`], baking it against `initial`. The one call that
/// touches a builder; see the module docs for why that has to happen at
/// once.
fn resolve_and_bake(
    initial: Vec<f64>,
    root: Fragment,
) -> TimelineHandle {
    let world = JsWorld { values: initial };
    let mut registry = Registry::new();

    let mut b = registry.create_builder::<JsWorld>();
    let track = resolve(&mut b, root.0).compile();
    let mut timeline = b.compile(track);
    // `b`, and its borrow of `registry`, is dropped here.

    timeline.bake_actions(&registry, &world);

    TimelineHandle {
        registry,
        timeline,
        world,
    }
}

/// A scope for signals and the timeline compiled from them. Create
/// signals with [`Self::create_signal`], resolve a [`Fragment`] tree
/// built from `act`/`chain`/`all`/`any`/`flow`/`delay` with
/// [`Self::compile`], then scrub it with [`Self::sample_at`] and read
/// values back with [`Self::get`].
#[wasm_bindgen]
pub struct Runtime {
    names: Vec<String>,
    initial: Vec<f64>,
    timeline: Option<TimelineHandle>,
}

#[wasm_bindgen]
impl Runtime {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Runtime {
        Runtime {
            names: Vec::new(),
            initial: Vec::new(),
            timeline: None,
        }
    }

    /// Registers a named subject with an initial value, returning its id.
    #[wasm_bindgen(js_name = createSignal)]
    pub fn create_signal(
        &mut self,
        name: String,
        initial: f64,
    ) -> Id {
        let id = self.names.len() as Id;
        self.names.push(name);
        self.initial.push(initial);
        id
    }

    /// Resolves, plays, orders, compiles, and bakes a timeline from `root`.
    pub fn compile(&mut self, root: Fragment) {
        self.timeline =
            Some(resolve_and_bake(self.initial.clone(), root));
    }

    /// The compiled track's duration, in seconds.
    #[wasm_bindgen(getter)]
    pub fn duration(&self) -> Result<f64, JsValue> {
        self.timeline_ref().map(TimelineHandle::duration)
    }

    /// Moves the playhead and samples. Call before reading any signal.
    #[wasm_bindgen(js_name = sampleAt)]
    pub fn sample_at(&mut self, seconds: f64) -> Result<(), JsValue> {
        self.timeline
            .as_mut()
            .ok_or_else(|| {
                err("sampleAt: compile() has not been called yet")
            })?
            .sample_at(seconds);
        Ok(())
    }

    /// Reads a signal's current value straight from the world (does not
    /// itself sample; call after `sampleAt`).
    pub fn get(&self, id: Id) -> Result<f64, JsValue> {
        let timeline = self.timeline_ref().map_err(|_| {
            let name = self.names.get(id as usize).map_or("?", String::as_str);
            err(format!(
                "signal \"{name}\" was read before compile() was called"
            ))
        })?;
        Ok(timeline.get(id))
    }

    fn timeline_ref(&self) -> Result<&TimelineHandle, JsValue> {
        self.timeline
            .as_ref()
            .ok_or_else(|| err("compile() has not been called yet"))
    }
}

impl Default for Runtime {
    fn default() -> Self {
        Self::new()
    }
}
