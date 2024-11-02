IMGAGE=sst
DEPS=Dockerfile

.PHONY: all
all: .image_build
.image_build: $(DEPS)
	docker build -t $(IMGAGE) .
	touch .image_build

bash: all
	docker run -it $(IMGAGE) bash

play: all
	docker run -it $(IMGAGE) bash -c "/root/sst"

clean:
	docker image rm $(IMGAGE)
	rm -f .image_build

help:
	@printf "\n\tall:   Simply builds the sst container image"
	@printf "\n\tbash:  Enters into a bash shell within the container"
	@printf "\n\tplay:  Starts up a thrilling round of SUPER STAR TREK"
	@printf "\n\tclean: Removes the image"
	@printf "\n\n"
