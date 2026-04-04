IMAGE_NAME=nrf51-dfu
DEPS=Dockerfile res/
KEEPFILE=.imagebuild_$(IMAGE_NAME)
#RFLAGS?=-it --network host
include ../Makefile.parent

res/:
	bash fetch_deps.sh

bins: build
	mkdir -p output
	docker run --rm -v $(pwd)/output:/output nrf51-dfu
