FROM debian:bookworm-slim

LABEL maintainer="ezbin@pm.me"
LABEL description="Lightweight headless cyber RE and hardware/network/binary analysis toolkit"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
#ENV LANG en_US.UTF-8

# Install base libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libusb-1.0-0 \
    libftdi1-2 \
    libudev1 \
    libstdc++6 \
    zlib1g \
    libncurses6 \
    libreadline8 \
    libffi8 \
    libssl3 \
    ca-certificates \
    libmagic1 \
    libpcap0.8 \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    less \
    most \
    vim \
    bc \
    curl \
    git \
    tmux \
    unzip \
    locales \
    && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# --- python ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    pipx \
    python3-capstone \
    python3-keystone \
    python3-unicorn \
    && rm -rf /var/lib/apt/lists/* \
    && pipx ensurepath

# --- Section: Hardware Hacking ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    usbutils \
    openocd \
    udev \
    screen \
    dosfstools \
    parted \
    flashrom \
    sigrok-cli \
    fxload \
    i2c-tools \
    bluez \
    dfu-util \
    && rm -rf /var/lib/apt/lists/*

# --- Section: Networking Tools ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap \
    netcat-traditional \
    socat \
    tcpdump \
    tshark \
    iputils-ping \
    traceroute \
    whois \
    dnsutils \
    arp-scan \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# --- Section: Binary/Forensics Tools ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc-arm-none-eabi gdb-arm-none-eabi \
    binutils \
    dwarfdump \
    binwalk \
    file \
    xxd \
    strace \
    ltrace \
    && rm -rf /var/lib/apt/lists/*

# --- Section: compression/decompresion tools for binwalk -e ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    gzip \
    bzip2 \
    tar \
    unrar-free \
    p7zip-full \
    cpio \
    zstd \
    lzop \
    xz-utils \
    squashfs-tools \
    e2tools \
    sleuthkit \
    && rm -rf /var/lib/apt/lists/*

# Manually copy jlink.deb
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxrender1 \
    libxcb-render0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-randr0 \
    libxcb-xfixes0 \
    libxcb-sync1 \
    libxcb-shm0 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-image0 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libfontconfig1 \
    libfreetype6 \
    libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://www.segger.com/downloads/jlink/JLink_Linux_V800c_x86_64.deb -o /tmp/jlink.deb && \
    apt-get update && apt-get install -y libncurses6 libusb-1.0-0 && \
    dpkg -i /tmp/jlink.deb || apt-get -fy install && \
    rm /tmp/jlink.deb
ENV PATH="${PATH}:/opt/SEGGER/JLink"

# --- gdb extra gef/pwndbg ---
#RUN bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
RUN git clone https://github.com/pwndbg/pwndbg.git /opt/pwndbg && \
    cd /opt/pwndbg && ./setup.sh

# -- nrfutil
# Source: https://academy.nordicsemi.com/courses/bluetooth-low-energy-fundamentals/lessons/lesson-6-bluetooth-le-sniffer/topic/nrf-sniffer-for-bluetooth-le/
RUN curl 'https://files.nordicsemi.com/ui/api/v1/download?repoKey=swtools&path=external/nrfutil/executables/x86_64-unknown-linux-gnu/nrfutil&isNativeBrowsing=false' > nrfutil \
    && chmod +x ./nrfutil \
    && ./nrfutil install ble-sniffer completion device \
    && ./nrfutil list \
    && rm ./nrfutil
ENV PATH="${PATH}:/root/.nrfutil/bin/"

# Configure bash environment
WORKDIR /root
RUN \
	git clone --recursive https://github.com/ErezBinyamin/dotfiles.git; \
	[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak; \
	printf '\n# Dotfiles: https://github.com/ErezBinyamin/dotfiles.git;\nDOTFILES=/root/dotfiles;\n[ -d ${DOTFILES} ] && source ${DOTFILES}/top.sh || echo "[ERROR] DirectoryNotFound: ${DOTFILES}";\n\n' >> ~/.bashrc;

# Clean up APT when done to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace
CMD ["/bin/bash"]

