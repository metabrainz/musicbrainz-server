TARGETS := $(shell find templates -name 'Dockerfile.*.m4' -exec basename '{}' .m4 \;)

all : $(TARGETS)

Dockerfile.% : templates/Dockerfile.%.m4
	./build.sh $*
