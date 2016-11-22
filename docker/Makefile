TARGETS := $(shell find templates -name 'Dockerfile.*.m4' -exec basename '{}' .m4 \;)
BUILD_TARGETS := $(filter-out build-cpanfile-snapshot,$(shell echo "$(TARGETS)" | sed s/Dockerfile\./build-/g))
PUSH_TARGETS := $(filter-out push-cpanfile-snapshot,$(shell echo "$(TARGETS)" | sed s/Dockerfile\./push-/g))

export GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null)
export GIT_MSG := $(shell git log -1 --format=format:"Last commit by %an on %ad: %s" --date=short)
export GIT_SHA := $(shell git log -1 --format=format:"%h")
export GIT_INFO := $(GIT_BRANCH):$(GIT_SHA):$(GIT_MSG)

.PHONY : $(BUILD_TARGETS) $(PUSH_TARGETS) config build-all push-all all

config :
	./generate_dockerfiles.sh $(TARGETS)

$(BUILD_TARGETS) :
	docker build --tag metabrainz/musicbrainz-$(subst build-,,$@):$(GIT_BRANCH) --file Dockerfile.$(subst build-,,$@) ../

$(PUSH_TARGETS) :
	docker push metabrainz/musicbrainz-$(subst push-,,$@):$(GIT_BRANCH)

build-all : $(BUILD_TARGETS)

push-all : $(PUSH_TARGETS)

all : config build-all push-all
