# Customization point: set the name of the binary built by Cargo.
ARG BINARY_NAME=app

ARG TINI_VERSION=v0.19.0

FROM rust:1-trixie AS chef
RUN cargo install --locked cargo-chef
WORKDIR /build

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
ARG BINARY_NAME
COPY --from=planner /build/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin $BINARY_NAME
RUN mkdir -p /empty

################################################################################

FROM gcr.io/distroless/cc-debian13:nonroot

ARG BINARY_NAME
ARG TINI_VERSION
ARG TARGETARCH

# Customization point: add labels you need, for example to indicate the repo location
# LABEL org.opencontainers.image.source=https://github.com/miikka/perfect-rust-dockerfile

ADD --chmod=755 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH} /bin/tini
COPY --from=builder /build/target/release/$BINARY_NAME /bin/app

# Customization point: add an empty directory owned by the nonroot user
# COPY --from=builder --chown=65532:65532 /empty /data

WORKDIR /app
EXPOSE 3000

# Customization point: if you need files other than the binary, copy them into the image here.
# COPY static/ static/

ENTRYPOINT [ "/bin/tini", "--" ]
CMD ["/bin/app"]
