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
    && rm -rf /var/lib/apt/lists/* \
    && pipx ensurepath

# --- Section: Dump1090 ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    fakeroot \
    debhelper \
    librtlsdr-dev \
    pkg-config \
    libncurses5-dev \
    libbladerf-dev \
    libhackrf-dev \
    liblimesuite-dev \
    libsoapysdr-dev \
    libusb-1.0-0-dev \
    devscripts \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
RUN git clone https://github.com/flightaware/dump1090.git && \
    cd dump1090 && \
    make

# Configure bash environment
WORKDIR /root
RUN \
	git clone --recursive https://github.com/ErezBinyamin/dotfiles.git; \
	[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak; \
	printf '\n# Dotfiles: https://github.com/ErezBinyamin/dotfiles.git;\nDOTFILES=/root/dotfiles;\n[ -d ${DOTFILES} ] && source ${DOTFILES}/top.sh || echo "[ERROR] DirectoryNotFound: ${DOTFILES}";\n\n' >> ~/.bashrc;
RUN printf '\n# flightaware/dump1090;\necho "$ cd dump1090";\necho "$ ./dump1090 --gain 40 --interactive --device-type hackrf";\n\n' >> ~/.bashrc;

# Clean up APT when done to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace
CMD ["/bin/bash"]

