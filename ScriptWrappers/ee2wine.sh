#!/bin/bash
# Functions that will launch docker containers
ee2wine() { 	
  # Error checking
  docker info &>/dev/null || { echo "Docker is not running"; return 1; }
  [ -z "${DISPLAY:-}" ] && { echo "DISPLAY is not set"; return 1; }

  # Main
	local IMAGE_NAME=${IMAGE_NAME:-erezbinyamin/ee2wine:latest}
  local USE_PULSEAUDIO=${USE_PULSEAUDIO:-0}
  docker image ls --format '{{.Repository}}:{{.Tag}}' | grep --quiet 'ee2wine:installed' && IMAGE_NAME=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -m1 'ee2wine:installed')
  
  # # Startup zerotier for LAN gaming
  if ! ifconfig | grep --quiet 'ztre.*:'
  then
    if ! docker ps | grep --quiet zerotier-one
    then
      docker run -d --name zerotier-one --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --volume /var/lib/zerotier-one:/var/lib/zerotier-one zyclonite/zerotier
      docker ps | grep --quiet zerotier-one || echo "Failed to start ZeroTier container"
    fi
  fi

	if [ -z "${XAUTHORITY:-${HOME}/.Xauthority}" ]
	then
		echo "ERROR: No valid .Xauthority file found for X11"
		return 1
	fi
	if ! docker image ls | grep "${IMAGE_NAME}" | grep --quiet ":latest"
	then
		docker pull "${IMAGE_NAME}"
	fi
	if ! docker volume ls -qf "name=winehome" | grep --quiet "^winehome$"
	then
		echo "INFO: Creating Docker volume container 'winehome'..."
		docker volume create winehome
	fi

  xhost +SI:localuser:$(id -un)
	xauth list "${DISPLAY}" | head -n1 | awk '{print $3}' > ~/.docker-wine.Xkey

	if [[ "${USE_PULSEAUDIO}" == '1' ]] && [ -e /tmp/pulse-socket ]
	then
		sudo chrt --fifo 99 docker run -it --rm \
			--name=wine2 \
			--hostname=$(hostname) \
			--shm-size=1g \
			--workdir=/ \
			--env=RUN_AS_ROOT=yes \
			--env=DISPLAY \
      --volume="/etc/localtime:/etc/localtime:ro" \
			--volume="/home/${USER}/.docker-wine.Xkey:/root/.Xkey:ro" \
			--volume="/tmp/pulse-socket:/tmp/pulse-socket" \
			--volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" \
			--volume="winehome:/home/wineuser" \
			--cap-add=NET_ADMIN \
			--net=host \
			--privileged \
			"${IMAGE_NAME}" bash &>/dev/null
	elif [ -d /tmp/.X11-unix ]
	then
		sudo chrt --fifo 99 docker run -it --rm \
			--name=wine2 \
			--hostname=$(hostname) \
			--shm-size=1g \
			--workdir=/ \
			--env=RUN_AS_ROOT=yes \
			--env=DISPLAY \
      --volume="/etc/localtime:/etc/localtime:ro" \
			--volume="/home/${USER}/.docker-wine.Xkey:/root/.Xkey:ro" \
			--volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" \
			--volume="winehome:/home/wineuser" \
			--cap-add=NET_ADMIN \
			--net=host \
			--privileged \
			"${IMAGE_NAME}" bash
	else
		echo "Unknown error: Go debug ee2wine.sh and have fun in docker wine land"
	fi
}
# Run if called with `bash ee2wine.sh`, Do not run if called by `source ee2wine.sh`
# Basically bash equiv of: if __name__ == "__main__"
[[ "$0" =~ "ee2wine.sh" ]] && ee2wine $@
