# Use the official Ubuntu LTS image as a base
FROM ubuntu:20.04

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
    python3 \
    python3-pip
RUN apt-get install -y --no-install-recommends \
    netcat \
    usbutils \
    nmap \
    tcpdump \
    tshark \
    net-tools \
    dnsutils \
    openocd \
    iputils-ping \
    build-essential \
    forensics-all
RUN apt-get install -y --no-install-recommends \
    whois

# Install additional Python packages for pentesting
RUN pip3 install --no-cache-dir \
    pwntools \
    chepy \
    requests

# Optional: Install Metasploit
#RUN curl https://raw.githubusercontent.com/rapid7/metasploit-framework/master/msfinstall | sh

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
