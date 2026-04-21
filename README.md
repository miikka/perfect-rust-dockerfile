A `Dockerfile` for a basic Rust backend app implemented with Axum.

* There's caching with cargo-chef.
* The resulting image is distroless and non-root.
* `tini` is not included; use `docker run --init` instead.
