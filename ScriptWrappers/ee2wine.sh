#!/bin/bash
# Functions that will launch docker containers
ee2wine() { 	
	local IMAGE_NAME=${IMAGE_NAME:-erezbinyamin/ee2wine:latest}
  docker images | grep -q 'ee2wine.*installed' && IMAGE_NAME=$(docker images | grep 'ee2wine.*installed' | sed 's/wine.*installed.*/wine:installed/')
	if [ -z "${XAUTHORITY:-${HOME}/.Xauthority}" ]
	then
		echo "ERROR: No valid .Xauthority file found for X11"
		return 1
	fi
	if ! docker images | grep -q ${IMAGE_NAME}
	then
		docker pull ${IMAGE_NAME}
	fi
	if [ "${USER_VOLUME}" == "winehome" ] && ! docker volume ls -qf "name=winehome" | grep -q "^winehome$"
	then
		echo "INFO: Creating Docker volume container 'winehome'..."
		docker volume create winehome
	fi

	xhost +local:$(id -un)
	xauth list "${DISPLAY}" | head -n1 | awk '{print $3}' > ~/.docker-wine.Xkey

	if false && [ -e /tmp/pulse-socket ]
	then
		sudo chrt --fifo 99 docker run -it --rm \
			--name=wine2 \
			--hostname=$(hostname) \
			--shm-size=1g \
			--workdir=/ \
			--env=RUN_AS_ROOT=yes \
			--env=DISPLAY \
			--env=TZ=America/New_York \
			--volume=/home/${USER}/.docker-wine.Xkey:/root/.Xkey:ro \
			--volume=/tmp/pulse-socket:/tmp/pulse-socket \
			--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
			--volume=winehome:/home/wineuser \
			--cap-add=NET_ADMIN \
			--net=host \
			--privileged \
			${IMAGE_NAME} bash &>/dev/null
	elif [ -d /tmp/.X11-unix ]
	then
		sudo chrt --fifo 99 docker run -it --rm \
			--name=wine2 \
			--hostname=$(hostname) \
			--shm-size=1g \
			--workdir=/ \
			--env=RUN_AS_ROOT=yes \
			--env=DISPLAY \
			--env=TZ=America/New_York \
			--volume=/home/${USER}/.docker-wine.Xkey:/root/.Xkey:ro \
			--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
			--volume=winehome:/home/wineuser \
			--cap-add=NET_ADMIN \
			--net=host \
			--privileged \
			${IMAGE_NAME} bash
	else
		echo "Unknown error: Go debug ee2wine.sh and have fun in docker wine land"
	fi
}
# Run if called with `bash ee2wine.sh`, Do not run if called by `source ee2wine.sh`
# Basically bash equiv of: if __name__ == "__main__"
[[ "$0" =~ "ee2wine.sh" ]] && ee2wine $@
