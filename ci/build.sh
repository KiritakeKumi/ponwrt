#!/bin/bash
# Container entrypoint: feeds -> config -> download -> compile.
# Everything (dl/, feeds/, build_dir/, ccache) lives in the bind-mounted /work,
# so repeated runs are incremental.
set -euo pipefail

BUILD_CONFIG="${BUILD_CONFIG:-configs/hm2004-du.config}"
JOBS="${JOBS:-$(nproc)}"
UPDATE_FEEDS="${UPDATE_FEEDS:-1}"
USE_CCACHE="${USE_CCACHE:-1}"

cd /work
[ -f "$BUILD_CONFIG" ] || { echo "config not found: $BUILD_CONFIG" >&2; exit 1; }

# github.com is flaky from some hosts; retry, and keep going on a stale feed checkout.
if [ "$UPDATE_FEEDS" = 1 ] || [ ! -d feeds/luci ]; then
	for try in 1 2 3; do
		./scripts/feeds update -a && break
		[ "$try" = 3 ] && { [ -d feeds/luci ] || { echo "feeds update failed" >&2; exit 1; }; echo "feeds update failed, using existing feeds" >&2; }
		sleep 10
	done
fi
./scripts/feeds install -a

if [ -n "${EXTRA_CONFIG:-}" ]; then
	./scripts/kconfig.pl + "$BUILD_CONFIG" "$EXTRA_CONFIG" > .config
else
	cp "$BUILD_CONFIG" .config
fi
if [ "$USE_CCACHE" = 1 ]; then
	export CCACHE_DIR=/work/.ccache
	echo "CONFIG_CCACHE=y" >> .config
fi
make defconfig

# Fail early if the intended profile / packages did not survive defconfig.
for sym in ${REQUIRE_SYMBOLS:-CONFIG_TARGET_MULTI_PROFILE=y CONFIG_TARGET_DEVICE_airoha_an7581_DEVICE_h3c_hm2004-du=y CONFIG_PACKAGE_luci-app-airoha-npu=y}; do
	grep -qx "$sym" .config || { echo "missing in .config: $sym" >&2; exit 1; }
done

make -j"$JOBS" download
make -j"$JOBS" || { echo "parallel build failed, retrying single-threaded for a readable log"; make -j1 V=s; }

# With per-device rootfs the *.manifest files are not trustworthy; check the rootfs apk db that went into the image.
rootdir=$(ls -dt build_dir/target-*/linux-*/target-dir-* | head -1)
for pkg in ${REQUIRE_PACKAGES:-wpad-openssl kmod-mt7915e kmod-airoha-en7572 kmod-phy-airoha-en8811h h3c-hm2004-du-mt7916-eeprom luci-app-airoha-npu}; do
	grep -qx "P:$pkg" "$rootdir/lib/apk/db/installed" || { echo "package missing from image rootfs: $pkg" >&2; exit 1; }
done

echo "== artifacts =="
ls -lh bin/targets/airoha/an7581/ 
