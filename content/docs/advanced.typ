#import "/templates/docs.typ": docs-page

#show: docs-page.with(title: "Building a Backend")

= Building a Backend

Bevy MotionGfx does exactly one thing: implement `SubjectSource` for
Bevy's `World`. That's the whole seam. This page is what building your
own looks like, whether that's a new backend or just skipping having one
at all.

== SubjectSource

```rust
pub trait SubjectSource<I: SubjectId, S: 'static> {
    fn get_source(&self, id: I) -> Option<&S>;
    fn apply_source<R>(&mut self, id: I, f: impl FnOnce(&mut S) -> R) -> Option<R>;
}
```

`I` is however you identify a subject: an index, an `Entity`, a string,
anything `Copy + Eq + Hash + Ord`. `S` is the type being animated on that
subject.

Implement it on your own world type. Rust's orphan rule means that type
has to be local to your crate; wrap a foreign type in a newtype if you
need to.

== Registry

`Registry::create_builder::<World>()` returns a builder typed to your
world. The registry is what lets `Track` and `Timeline` stay non-generic
internally while still animating whatever types you give them. You
create one, pass it around, and otherwise don't touch it.

== Interpolation

A subject type needs `Interpolation<M>` for some marker `M`:

```rust
pub trait Interpolation<M> {
    fn interp(a: &Self, b: &Self, t: f32) -> Self;
}
```

`f32`, `f64`, `i32`, `u32`, and `u8` already have one built in. For your
own types, or foreign ones like Peniko's `Color`, implement it under a
marker type of your own. That's what `peniko_motiongfx`'s `Peniko` marker
is for.

== Reference

This page stays conceptual. For exact types and signatures, see
#link("https://docs.rs/motiongfx")[docs.rs].
