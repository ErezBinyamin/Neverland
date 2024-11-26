FROM scottyhardy/docker-wine:latest

RUN apt-get update --fix-missing
RUN apt-get install --install-recommends -y wine-staging winetricks;
RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    python3-pip
RUN pip install gdown

# Download install materials
WORKDIR /home
#RUN  wget "https://file5.gofile.io/download/direct/6ecaf080-a673-475e-ab57-cae6ddfcc272/EE_Setup.exe" \
#	wget -N "https://patch.ee2.eu/patch15/linux/EE2-Linux-Install.bash"; \
RUN gdown --fuzzy "https://drive.google.com/file/d/1Y5_bQ0B6zwKfVSLFgQNF9FRoeHbyJkNW/view?usp=sharing" # EE_Setup.exe
RUN gdown --fuzzy "https://drive.google.com/file/d/1uB4JCDgU0_SiyHB1jofleotKjnZkAVW9/view?usp=sharing" # EE2-Linux-Install.bash
#RUN chmod +x ./EE2-Linux-Install.bash; \
#	sed -i "s/sudo//g; s/-fR//g" ./EE2-Linux-Install.bash

RUN echo printf '"=== To complete EE installation run the following commands ===\n\n"' >> /root/.bashrc; \
	echo printf '"\n# 1.\n"' >> /root/.bashrc; \
	echo printf '"/EE2-Linux-Install.bash\n"' >> /root/.bashrc; \
	echo printf '"\n# 2.\n"' >> /root/.bashrc; \
	echo printf '"WINEPREFIX="$HOME/.PlayOnLinux/wineprefix/Games/" WINEARCH=win32 WINE="/opt/wine-staging/bin/wine" LIBGL_ALWAYS_SOFTWARE=1 /opt/wine-staging/bin/wine EE_Setup.exe\n"' >> /root/.bashrc; \
	echo printf '"\n# 3.\n"' >> /root/.bashrc; \
	echo printf '"cd \"/root/.PlayOnLinux/wineprefix/Games/drive_c/Program Files/Empire Earth/Empire Earth\"\n"' >> /root/.bashrc; \
	echo printf '"WINEPREFIX=\"$HOME/.PlayOnLinux/wineprefix/Games/\" WINEARCH=win32 WINE=\"/opt/wine-staging/bin/wine\" LIBGL_ALWAYS_SOFTWARE=1 wine \"./Empire Earth.exe\"\n\n"' >> /root/.bashrc; \
	echo printf '"\n# 4.\n"' >> /root/.bashrc; \
	echo printf '"cd \"cd "/root/.PlayOnLinux/wineprefix/Games/drive_c/Program Files/Empire Earth/Empire Earth - The Art of Conquest"/"\n"' >> /root/.bashrc; \
	echo printf '"WINEPREFIX=\"$HOME/.PlayOnLinux/wineprefix/Games/\" WINEARCH=win32 WINE=\"/opt/wine-staging/bin/wine\" LIBGL_ALWAYS_SOFTWARE=1 wine \"./EE-AOC.exe\"\n\n"' >> /root/.bashrc; \


