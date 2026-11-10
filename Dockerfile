# Static, multi-arch Noddy CLI (Noddyverse build, incl. the RANDOM history generator).
#
#   docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/whatnick/noddyverse:dev .
#
# Builder: Alpine/musl so the binary is fully static and runs in ANY Linux image
# (glibc or musl, old or new) -- e.g. copied into a large training image by a
# Kubernetes init container. Runtime: busybox, so `cp` exists for that copy step.
# The file list is taken from upstream src/compile.sh, so the build tracks upstream.
FROM --platform=$BUILDPLATFORM alpine:3.20 AS src
WORKDIR /src
COPY src/ ./

FROM alpine:3.20 AS build
RUN apk add --no-cache build-base
WORKDIR /src
COPY --from=src /src/ ./
# compile.sh: `gcc -O3 -g3 -o noddy <files> -lm -w` -> static, stripped, at /out/noddy
RUN mkdir -p /out \
 && cmd="$(grep -E '^gcc ' compile.sh | sed -e 's/ -g3//' -e 's# -o noddy # -static -s -o /out/noddy #')" \
 && echo "$cmd" | grep -q -- '-static' \
 && sh -c "$cmd" \
 && /out/noddy 2>&1 | grep -q 'Arguments <historyfile>' \
 && (file /out/noddy 2>/dev/null || true)

FROM busybox:1.36-musl
LABEL org.opencontainers.image.source="https://github.com/whatnick/noddyverse" \
      org.opencontainers.image.description="Static Noddy CLI (Noddyverse build) with FM4G seeded RANDOM history patch; BLOCK / BLOCK_GEOPHYS / RANDOM modes" \
      org.opencontainers.image.licenses="MIT"
COPY --from=build /out/noddy /usr/local/bin/noddy
COPY LICENSE* /usr/share/doc/noddyverse/
# Usage: noddy <historyfile> <outputprefix> BLOCK|GEOPHYSICS|BLOCK_GEOPHYS|RANDOM ...
#   RANDOM env: NODDY_SEED, NODDY_CUBE, NODDY_HIS_ONLY, NODDY_MIN_DYKE_W, NODDY_MIN_LAYER_H
ENTRYPOINT ["/usr/local/bin/noddy"]
