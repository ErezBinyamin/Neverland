FROM debian:bookworm-slim

LABEL maintainer="ezbin@pm.me"
LABEL description="Lightweight headless cyber RE and hardware/network/binary analysis toolkit"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install base libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libusb-1.0-0 libudev1 libstdc++6 zlib1g libncurses6 libreadline8 \
    libffi8 libssl3 ca-certificates libmagic1 libpcap0.8 \
    && rm -rf /var/lib/apt/lists/*

# Install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    most \
    vim \
    bc \
    curl \
    git \
    tmux \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

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
    lsof \
    strace \
    ltrace \
    && rm -rf /var/lib/apt/lists/*

# --- gef ---
RUN bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

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

