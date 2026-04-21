default: run

build:
    docker build -t perfect-rust-dockerfile .

run: build
    docker run --rm -it -p 127.0.0.1:3000:3000 perfect-rust-dockerfile
