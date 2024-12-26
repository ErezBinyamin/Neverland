IMAGE_NAME=sst
DEPS=Dockerfile
BFLAGS=--platform linux/386
include ../Makefile.parent

play: build
	cat splash.txt
	docker run -it sst /root/sst 
