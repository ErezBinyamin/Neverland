IMAGE_NAME=analyze
DEPS=Dockerfile
KEEPFILE=.imagebuild_$(IMAGE_NAME)
RFLAGS?=-it --network host --user $(shell id -u):$(shell id -g) --volume ./res:/root/res
include ../Makefile.parent
