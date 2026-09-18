//! A drawable shape every demo's `World` can produce, so the site needs
//! exactly one JS-side renderer (`assets/js/mgfx-demo.js`'s
//! `drawShapes`) instead of a bespoke `draw()` per demo: a `World`
//! encodes what it contains as circles and rects, not just bare
//! numbers, and the renderer only ever has to know how to draw those
//! two things.

pub struct Circle {
    pub x: f64,
    pub y: f64,
    pub radius: f64,
}

pub struct Rect {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

pub enum Shape {
    Circle(Circle),
    Rect(Rect),
}

impl Shape {
    /// Flattened as `[kind, x, y, a, b]`, both kinds anchored at their
    /// center: kind `0` is a circle (`a` = radius, `b` unused), kind
    /// `1` is a rect (`a` = width, `b` = height). Flat `f64`s, not a
    /// richer JS-facing type, because that's the shape wasm-bindgen
    /// hands back without extra glue (see `BarsDemo::heights` before
    /// this module existed).
    fn write(&self, out: &mut Vec<f64>) {
        match self {
            Shape::Circle(c) => {
                out.extend_from_slice(&[0.0, c.x, c.y, c.radius, 0.0])
            }
            Shape::Rect(r) => out.extend_from_slice(&[
                1.0, r.x, r.y, r.width, r.height,
            ]),
        }
    }
}

/// Flattens a demo's shapes into the array its `shapes()` wasm export
/// hands to JS.
pub fn flatten(shapes: impl IntoIterator<Item = Shape>) -> Vec<f64> {
    let mut out = Vec::new();
    for shape in shapes {
        shape.write(&mut out);
    }
    out
}
