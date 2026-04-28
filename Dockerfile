FROM alpine AS build

ARG TARGETARCH
ARG NODE_VERSION

COPY ./*.diff /

COPY --chmod=0755 <<EOF /usr/bin/node-server
#!/bin/sh
case "${TARGETARCH}" in
  arm64) echo "nodejs.org" ;;
  riscv64) echo "unofficial-builds.nodejs.org" ;;
esac
EOF

COPY --chmod=0755 <<EOF /usr/bin/arch-linker-musl
#!/bin/sh
case "${TARGETARCH}" in
  arm64) echo "aarch64" ;;
  riscv64) echo "riscv64" ;;
esac
EOF

COPY --chmod=0755 <<EOF /usr/bin/arch-linker-glibc
#!/bin/sh
case "${TARGETARCH}" in
  arm64) echo "aarch64" ;;
  riscv64) echo "riscv64-lp64d" ;;
esac
EOF

RUN apk add build-base curl git
RUN curl -L "https://$(node-server)/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${TARGETARCH}.tar.xz" | tar xJf -
RUN git clone https://github.com/laverdet/adelie-gcompat.git gcompat
RUN cat gcompat-${TARGETARCH}.diff | git -C gcompat apply
RUN make -C gcompat LINKER_PATH=/lib/ld-musl-$(arch-linker-musl).so.1 LOADER_NAME=ld-linux-$(arch-linker-glibc).so.1 all install
RUN /node-v${NODE_VERSION}-linux-${TARGETARCH}/bin/node -e 'console.log("Hello world.")'
RUN mkdir -p /output/lib
RUN cp /lib/libgcompat.so.0 /lib/ld-linux-$(arch-linker-glibc).so.1 /output/lib

FROM scratch
COPY --from=build /output/ /

