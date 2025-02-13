# Use the official Ubuntu LTS image as a base
FROM python:latest

# Set the timezone to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Update the package list and install essential tools
RUN apt-get update --fix-missing
RUN apt-get install -y --no-install-recommends \
    bc \
    curl \
    wget \
    git \
    vim \
    snapd \
    python3-full \
    python3-pip \
    pipx \
    software-properties-common \
    bsdmainutils
RUN git clone https://github.com/radareorg/radare2.git /opt/radare2 \
    && /opt/radare2/sys/install.sh
RUN apt-get install -y --no-install-recommends \
    usbutils \
    openocd \
    udev \
    screen \
    dosfstools \
    parted
RUN apt-get install -y --no-install-recommends \
    netcat-traditional \
    nmap \
    tcpdump \
    tshark \
    whois \
    mtr
RUN apt-get install -y --no-install-recommends \
    build-essential \
    binwalk \
    forensics-all \
    net-tools \
    iputils-ping \
    dnsutils \
    aircrack-ng \
    binutils \
    binutils-arm-none-eabi \
    netwox \
    traceroute

# Install additional Python packages for pentesting
RUN pipx ensurepath
RUN pipx install \
    pwntools
# Optional: Install Metasploit
#RUN curl https://raw.githubusercontent.com/rapid7/metasploit-framework/master/msfinstall | sh

# Install pwndbg
RUN git clone --recursive https://github.com/pwndbg/pwndbg.git; \
    cd pwndbg; \
    ./setup.sh

# Configure bash environment
WORKDIR /root
RUN \
	git clone --recursive https://github.com/ErezBinyamin/dotfiles.git; \
	[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak; \
	printf '\n# Dotfiles: https://github.com/ErezBinyamin/dotfiles.git;\nDOTFILES=/root/dotfiles;\n[ -d ${DOTFILES} ] && source ${DOTFILES}/top.sh || echo "[ERROR] DirectoryNotFound: ${DOTFILES}";\n\n' >> ~/.bashrc;

# Clean up APT when done to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt update

# Set working directory
WORKDIR /root

# Entry point for the container
ENTRYPOINT ["/bin/bash"]
