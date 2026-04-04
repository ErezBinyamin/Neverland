# nRF51822 / nRF5 SDK 12.3.0 build environment
# Produces signed Secure DFU bootloader + application + OTA .zip package
#
# Prerequisites:
#   ./fetch_deps.sh        # download dependencies into ./res once
#   docker build -t nrf51-dfu .
#   docker run --rm -v $(pwd)/output:/output nrf51-dfu

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SDK_DIR=/opt/nRF5_SDK_12.3.0_d7731ad
ENV GNU_INSTALL_ROOT=/opt/gcc-arm-none-eabi-4_9-2015q3
ENV GNU_VERSION=4.9.3
ENV GNU_PREFIX=arm-none-eabi
ENV PATH="${GNU_INSTALL_ROOT}/bin:${PATH}"

# ── System deps ───────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    make \
    unzip \
    bzip2 \
    python3 python3-pip \
    libncurses5 \
    libc6-i386 \
    && rm -rf /var/lib/apt/lists/*

# ── ARM GCC 4.9 ───────────────────────────────────────────────────────────────
COPY res/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2 /tmp/
RUN tar xf /tmp/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2 -C /opt \
    && rm /tmp/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2

# ── nRF5 SDK 12.3.0 ───────────────────────────────────────────────────────────
COPY res/nRF5_SDK_12.3.0_d7731ad.zip /tmp/
RUN unzip -q /tmp/nRF5_SDK_12.3.0_d7731ad.zip -d /opt \
    && rm /tmp/nRF5_SDK_12.3.0_d7731ad.zip

# Patch the GCC toolchain config for this container's paths
RUN printf "GNU_INSTALL_ROOT := %s\nGNU_VERSION := %s\nGNU_PREFIX := %s\n" \
    "${GNU_INSTALL_ROOT}" "${GNU_VERSION}" "${GNU_PREFIX}" \
    > ${SDK_DIR}/components/toolchain/gcc/Makefile.posix

# ── micro-ecc (required for Secure DFU bootloader) ────────────────────────────
COPY res/micro-ecc.tar.gz /tmp/
RUN tar xf /tmp/micro-ecc.tar.gz -C /tmp \
    && mv /tmp/micro-ecc-master ${SDK_DIR}/external/micro-ecc/micro-ecc \
    && rm /tmp/micro-ecc.tar.gz \
    && cd ${SDK_DIR}/external/micro-ecc/nrf51_armgcc/armgcc \
    && make

# ── nrfutil (key generation + DFU package signing) ────────────────────────────
RUN pip3 install nrfutil==6.1.7

# ── Generate signing keys ─────────────────────────────────────────────────────
# In production: COPY your own private key instead of generating one here,
# so the same key is used across all builds.
#   COPY my_private_key.pem /keys/private_key.pem
RUN mkdir -p /keys \
    && nrfutil keys generate /keys/private_key.pem \
    && nrfutil keys display --key pk --format code /keys/private_key.pem \
       > ${SDK_DIR}/examples/dfu/bootloader_secure/dfu_public_key.c \
    && grep -q "pk\[64\]" ${SDK_DIR}/examples/dfu/bootloader_secure/dfu_public_key.c \
    || (echo "ERROR: dfu_public_key.c missing pk symbol" && exit 1)

# ── Build the Secure DFU bootloader ───────────────────────────────────────────
RUN cd ${SDK_DIR}/examples/dfu/bootloader_secure/pca10028/armgcc \
    && make

# ── Build the example application (BLE Blinky with S130) ──────────────────────
RUN cd ${SDK_DIR}/examples/ble_peripheral/experimental_ble_app_blinky/pca10028/s130/armgcc \
    && make

# ── Generate the DFU .zip package ─────────────────────────────────────────────
RUN mkdir -p /output_staging && \
    nrfutil pkg generate \
    --application ${SDK_DIR}/examples/ble_peripheral/experimental_ble_app_blinky/pca10028/s130/armgcc/_build/nrf51422_xxac.hex \
    --application-version 1 \
    --hw-version 51 \
    --sd-req 0x8C \
    --key-file /keys/private_key.pem \
    /output_staging/app_dfu_v1.zip

# ── Stage all artifacts ───────────────────────────────────────────────────────
RUN cp ${SDK_DIR}/components/softdevice/s130/hex/s130_nrf51_2.0.1_softdevice.hex \
       /output_staging/ && \
    cp ${SDK_DIR}/examples/dfu/bootloader_secure/pca10028/armgcc/_build/nrf51422_xxac_s130.hex \
       /output_staging/bootloader.hex && \
    cp ${SDK_DIR}/examples/ble_peripheral/experimental_ble_app_blinky/pca10028/s130/armgcc/_build/nrf51422_xxac.hex \
       /output_staging/app.hex && \
    cp /keys/private_key.pem /output_staging/

# ── Entrypoint: copy artifacts to the mounted /output volume ──────────────────
ENTRYPOINT ["/bin/bash", "-c", "cp -r /output_staging/* /output/ && echo '\nDone. Files written to /output:\n' && ls /output"]
