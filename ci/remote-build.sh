#!/bin/bash
# Build the committed HEAD on a remote Docker host and fetch the images back.
#   ci/remote-build.sh [--clean]
# Env: REMOTE (default root@172.16.10.3), REMOTE_DIR, BUILD_CONFIG, JOBS, OUT_DIR
set -euo pipefail

REMOTE="${REMOTE:-root@172.16.10.3}"
REMOTE_DIR="${REMOTE_DIR:-/opt/ponwrt-ci}"
OUT_DIR="${OUT_DIR:-out}"
BUILD_UID=1000

cd "$(git rev-parse --show-toplevel)"
git diff --quiet HEAD || { echo "uncommitted changes: commit first (only HEAD is built)" >&2; exit 1; }

ssh "$REMOTE" "mkdir -p $REMOTE_DIR/src"
[ "${1:-}" = "--clean" ] && ssh "$REMOTE" "rm -rf $REMOTE_DIR/src && mkdir -p $REMOTE_DIR/src"

# Overwrites tracked files only; dl/, feeds/, build_dir/, .ccache survive for incremental builds.
git archive HEAD | ssh "$REMOTE" "tar -x -C $REMOTE_DIR/src && chown -R $BUILD_UID:$BUILD_UID $REMOTE_DIR/src"

# git archive has no .git, and apk rejects the resulting "unknown" version; scripts/getver.sh honours ./version.
REV="r0+$(git rev-list --count HEAD)-$(git rev-parse --short=10 HEAD)"
echo "$REV" | ssh "$REMOTE" "cat > $REMOTE_DIR/src/version && chown $BUILD_UID:$BUILD_UID $REMOTE_DIR/src/version"

ssh "$REMOTE" "cd $REMOTE_DIR/src && \
  SRC_DIR=$REMOTE_DIR/src BUILD_UID=$BUILD_UID BUILD_CONFIG=${BUILD_CONFIG:-configs/hm2004-du.config} JOBS=${JOBS:-} \
  docker compose -f ci/docker-compose.yml run --rm --build builder"

mkdir -p "$OUT_DIR"
scp "$REMOTE:$REMOTE_DIR/src/bin/targets/airoha/an7581/*hm2004-du*" "$REMOTE:$REMOTE_DIR/src/bin/targets/airoha/an7581/sha256sums" "$OUT_DIR/"
echo "images in $OUT_DIR/"
