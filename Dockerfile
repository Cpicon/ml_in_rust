# build stage
FROM --platform=linux/arm64/v8 rust:latest as cargo-build

RUN apt-get update && apt-get install musl-tools -y
RUN rustup update && rustup target add aarch64-unknown-linux-musl

WORKDIR /usr/src/app

COPY . .

RUN cargo clean
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=aarch64-unknown-linux-musl

# final stage
FROM --platform=linux/arm64/v8 alpine:latest

RUN addgroup -g 1000 app
RUN adduser -D -s /bin/sh -u 1000 -G app app

WORKDIR /home/app/bin/

COPY --from=cargo-build /usr/src/app/target/aarch64-unknown-linux-musl/release/twitter-clone-rust .

RUN chown app:app twitter-clone-rust
USER app

EXPOSE 9090

CMD ["./twitter-clone-rust"]