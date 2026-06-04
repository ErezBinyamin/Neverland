IMAGE_NAME=sst
DEPS=Dockerfile bashrc art/
BFLAGS=--platform linux/386
include ../Makefile.parent

play: build
	cat splash.txt
	docker run -it sst /root/sst 
