WORKDIR=$(shell pwd)/workdir
IMAGE_VERSION ?= $(shell date +"%Y.%m.%d")
PACKAGES=vim git curl wget fzf man-db man-pages texinfo sudo zsh micro nano

.PHONY: build test clean

build: 
	scripts/build-image.sh $(WORKDIR) $(IMAGE_VERSION) $(PACKAGES)

test:
	scripts/test-image.sh $(WORKDIR) $(IMAGE_VERSION)

clean:
	rm -rf $(WORKDIR)
