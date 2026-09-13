#import "/templates/docs.typ": docs-page

#show: docs-page.with(title: "Actions")

= Actions

This page applies to every backend the same way. Whichever one you
picked, you already have a builder, called `b` below.

== Describing a change

An action says what should change, not how long it takes.

```rust
let action = b.act(subject, path!(<Type>::field), |current| new_value);
```

- `subject`: which thing to animate. An id, a Bevy `Entity`, whatever your
  backend uses.
- `path!(<Type>::field)`: which field on it.
- The closure: takes the field's current value, returns its target value.

== Giving it timing

`.play(duration)` turns an action into a `TrackFragment`.

```rust
let fragment = action.play(s(1));
```

Add an easing function before `.play()` to change how it moves between
the two values, instead of a straight line:

```rust
let fragment = action.with_ease(ease::cubic::ease_in_out).play(s(1));
```
