# Build environment for PonWrt / ImmortalWrt (Airoha AN7581 / HM2004-DU).
# OpenWrt refuses to build as root, so everything runs as an unprivileged user.
FROM debian:12

ARG DEBIAN_MIRROR=
ARG BUILD_UID=1000
ARG BUILD_GID=1000

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

RUN if [ -n "$DEBIAN_MIRROR" ]; then \
      sed -i "s#http[s]*://deb.debian.org#${DEBIAN_MIRROR}#g" /etc/apt/sources.list.d/debian.sources; \
    fi \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
      bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext \
      gcc-multilib g++-multilib git gnutls-dev gperf help2man intltool libc6-dev-i386 \
      libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev \
      libpython3-dev libreadline-dev libssl-dev libtool libyaml-dev zlib1g-dev lld llvm \
      lrzsz genisoimage ninja-build p7zip-full patch pkgconf python3 python3-pip python3-ply \
      python3-docutils python3-pyelftools python3-setuptools qemu-utils re2c rsync scons \
      squashfs-tools subversion swig texinfo uglifyjs unzip vim wget xmlto xxd zstd \
      file ca-certificates sudo \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g "$BUILD_GID" build \
 && useradd -m -u "$BUILD_UID" -g build -s /bin/bash build

COPY --chmod=0755 build.sh /usr/local/bin/ponwrt-build

USER build
WORKDIR /work
ENTRYPOINT ["ponwrt-build"]
