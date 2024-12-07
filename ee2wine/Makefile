IMAGE_NAME?=ee2wine
DEPS=Dockerfile bashrc splash.txt
include ../Makefile.parent
ZEROTIER_NETWORK_ID=272f5eae16481824

play: connect bash
bash: build
	IMAGE_NAME=$(IMAGE_NAME) bash ee2wine.sh

connect:
	docker ps | grep -q 'zerotier' || docker run -d --name zerotier-one --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --volume /var/lib/zerotier-one:/var/lib/zerotier-one zyclonite/zerotier
	docker exec zerotier-one zerotier-cli join $(ZEROTIER_NETWORK_ID)

