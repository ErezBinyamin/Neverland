IMAGE_NAME=ee2wine
DEPS=Dockerfile bashrc splash.txt
KEEPFILE=.imagebuild_$(IMAGE_NAME)
include ../Makefile.parent

bash: build
	bash ee2wine.sh
