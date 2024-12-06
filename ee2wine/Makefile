IMAGE_NAME=ee2wine
DEPS=Dockerfile bashrc splash.txt
KEEPFILE=.imagebuild_$(IMAGE_NAME)
include ../Makefile.parent

bash: build
	IMAGE_NAME=$(IMAGE_NAME) bash ee2wine.sh
