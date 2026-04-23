# Customization point: set the name of the binary built by Cargo.
ARG BINARY_NAME=app

FROM rust:1-trixie AS chef
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    cargo install --locked cargo-chef
WORKDIR /build

FROM chef AS planner
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
ARG BINARY_NAME
RUN mkdir -p /empty
COPY --from=planner /build/recipe.json recipe.json
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/build/target \
     cargo chef cook --release --recipe-path recipe.json
COPY . .
# We have to copy the binary out of `target` as the last step because it is a cache mount.
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/build/target \
    cargo build --release --bin "$BINARY_NAME" && \
    cp "target/release/$BINARY_NAME" app

################################################################################

FROM gcr.io/distroless/cc-debian13:nonroot

# Customization point: add labels you need, for example to indicate the repo location
# LABEL org.opencontainers.image.source=https://github.com/miikka/perfect-rust-dockerfile

WORKDIR /app
COPY --from=builder /build/app /app/app

# Customization point: add an empty directory owned by the nonroot user
# COPY --from=builder --chown=65532:65532 /empty /data

# Customization point: if you need files other than the binary, copy them into the image here.
# COPY static/ static/

# No `tini` here as the entrypoint, so unless your app handles signals explicitly, use
# `docker run --init` to ensure that Ctrl-C and SIGTERM work.
CMD ["/app/app"]
