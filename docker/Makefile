TARGETS := $(shell find templates -name 'Dockerfile.*.m4' -exec basename '{}' .m4 \;)
BUILD_TARGETS := $(filter-out build-cpanfile-snapshot,$(shell echo "$(TARGETS)" | sed s/Dockerfile\./build-/g))
PUSH_TARGETS := $(filter-out push-cpanfile-snapshot,$(shell echo "$(TARGETS)" | sed s/Dockerfile\./push-/g))

export GIT_BRANCH := $(shell ../script/git_info branch)
export GIT_MSG := $(shell ../script/git_info msg)
export GIT_SHA := $(shell ../script/git_info sha)

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
