FROM scottyhardy/docker-wine:latest

RUN apt-get update --fix-missing
RUN apt-get install --install-recommends -y wine-staging winetricks;
RUN apt-get install -y --no-install-recommends \
    net-tools \
    iputils-ping \
    python3 \
    python3-pip
RUN pip install gdown

# Download install materials
WORKDIR /root
#RUN  wget "https://file5.gofile.io/download/direct/6ecaf080-a673-475e-ab57-cae6ddfcc272/EE_Setup.exe" \
#	wget -N "https://patch.ee2.eu/patch15/linux/EE2-Linux-Install.bash"; \
RUN gdown --fuzzy "https://drive.google.com/file/d/1Y5_bQ0B6zwKfVSLFgQNF9FRoeHbyJkNW/view?usp=sharing" # EE_Setup.exe
RUN gdown --fuzzy "https://drive.google.com/file/d/1uB4JCDgU0_SiyHB1jofleotKjnZkAVW9/view?usp=sharing" # EE2-Linux-Install.bash

RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    bc \
    git

RUN chmod +x ./EE2-Linux-Install.bash; \
	sed -i "s/sudo//g; s/-fR//g" ./EE2-Linux-Install.bash

COPY splash.txt /home/splash.txt
COPY bashrc /root/.bashrc
COPY bashrc /home/.bashrc
# The rest of the install needs to be done manually after being launched with correct envars and whatnot (GUI stuff)
# See gist: https://gist.github.com/ErezBinyamin/6199e8fe1388c0521d6398e380641cdf
