# ForEign Rust Routine InterfaCe

f.e.r.r.i.c. is a completely automatic FFI from Haskell to Rust. It allows you to use any Rust crate seamlessly from Haskell, without writing any bindings yourself.

Rust’s type system is [inspired](https://doc.rust-lang.org/reference/influences.html) by Haskell’s, and maps injectively to Haskell. f.e.r.r.i.c. takes advantage of this by generating, for any given Rust crate:

- A Haskell `class` for every Rust `trait`
- A Haskell `data` for every Rust `enum` and `struct`
- A Haskell `HasField` instance for every Rust `impl` function

## Usage

Just add

```haskell
module Your.Rust.Crate.Root

import Ferric

crate "crate-name"
```

## Mechanism of action

f.e.r.r.i.c. relies on [docs.rs’ rustdoc JSON](https://docs.rs/about/rustdoc-json) to know what bindings to generate. During build, it downloads the JSON from [docs.rs](https://docs.rs). You can optionally point it to a local copy of the rustdoc JSON if you want to avoid using the Internet during build with `crate'`, which takes a JSON blob.

The JSON is converted via Template Haskell to `foreign` calls to generated `extern "C"` Rust in a temporary local crate that is built and linked with the final Haskell objects. Ensure that you have `cargo` on your `PATH` during build for this reason.
