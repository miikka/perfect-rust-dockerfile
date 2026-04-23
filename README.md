A `Dockerfile` for a basic Rust backend app implemented with Axum.

* There's caching with cargo-chef.
* The resulting image is distroless and non-root.
* `tini` is not included; use `docker run --init` instead.

## References

Using cargo-chef:
- https://github.com/lukemathwalker/cargo-chef

Using cache mounts for Cargo:
- https://docs.docker.com/build/cache/optimize/#use-cache-mounts
- https://doc.rust-lang.org/cargo/guide/cargo-home.html#caching-the-cargo-home-in-ci

Using `--init`/tini:
- https://docs.docker.com/reference/cli/docker/container/run/#init
- https://docs.docker.com/reference/compose-file/services/#init
- https://github.com/krallin/tini

Distroless images:
- https://github.com/googlecontainertools/distroless
- https://github.com/GoogleContainerTools/distroless/tree/main/cc
