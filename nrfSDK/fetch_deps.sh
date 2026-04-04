#!/usr/bin/env bash
# fetch_deps.sh
# Downloads all external dependencies needed to build the nRF51822 DFU image.
# Run this once before `docker build`.
# Output: ./res/

set -euo pipefail

RES_DIR="$(dirname "$0")/res"
mkdir -p "$RES_DIR"

echo "==> Downloading dependencies into $RES_DIR"

# ── ARM GCC 4.9 (exact version Nordic tested SDK 12.3 with) ──────────────────
GCC_ARCHIVE="gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2"
GCC_URL="https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q3-update/+download/${GCC_ARCHIVE}"
if [ ! -f "$RES_DIR/$GCC_ARCHIVE" ]; then
    echo "--> ARM GCC 4.9..."
    wget -q --show-progress -O "$RES_DIR/$GCC_ARCHIVE" "$GCC_URL"
else
    echo "--> ARM GCC 4.9 already present, skipping."
fi

# ── nRF5 SDK 12.3.0 ───────────────────────────────────────────────────────────
SDK_ARCHIVE="nRF5_SDK_12.3.0_d7731ad.zip"
SDK_URL="https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v12.x.x/${SDK_ARCHIVE}"
if [ ! -f "$RES_DIR/$SDK_ARCHIVE" ]; then
    echo "--> nRF5 SDK 12.3.0..."
    wget -q --show-progress -O "$RES_DIR/$SDK_ARCHIVE" "$SDK_URL"
else
    echo "--> nRF5 SDK 12.3.0 already present, skipping."
fi

# ── micro-ecc ─────────────────────────────────────────────────────────────────
# Clone as a tar.gz snapshot so we don't need git inside the container
MICRO_ECC_ARCHIVE="micro-ecc.tar.gz"
MICRO_ECC_URL="https://github.com/kmackay/micro-ecc/archive/refs/heads/master.tar.gz"
if [ ! -f "$RES_DIR/$MICRO_ECC_ARCHIVE" ]; then
    echo "--> micro-ecc..."
    wget -q --show-progress -O "$RES_DIR/$MICRO_ECC_ARCHIVE" "$MICRO_ECC_URL"
else
    echo "--> micro-ecc already present, skipping."
fi

# ── get-pip.py (needed to bootstrap pip on python3.10) ────────────────────────
GETPIP="get-pip.py"
GETPIP_URL="https://bootstrap.pypa.io/get-pip.py"
if [ ! -f "$RES_DIR/$GETPIP" ]; then
    echo "--> get-pip.py..."
    wget -q --show-progress -O "$RES_DIR/$GETPIP" "$GETPIP_URL"
else
    echo "--> get-pip.py already present, skipping."
fi
ls -lh "$RES_DIR"
echo ""
echo "You can now run: docker build -t nrf51-dfu ."
