REGISTRY := registry.hkoerber.de
APPNAME := blog
PUSHURL := $(REGISTRY)/$(APPNAME)

RESUME := static/assets/resume/resume.pdf

.PHONY: all
all: | build image image-push

.PHONY: resume
resume:
	(cd contrib/resume && $(MAKE) pdf)
	cp contrib/resume/resume.pdf $(RESUME)

.PHONY: assets
assets: resume

.PHONY: build
build:
	bundle exec jekyll build --config=./_config.yml,./_config.$(TARGET).yml

.PHONY: image
image:
	docker build \
		--tag $(REGISTRY)/$(APPNAME) \
		--tag $(REGISTRY)/$(APPNAME):$${DRONE_COMMIT_BRANCH} \
		--tag $(REGISTRY)/$(APPNAME):$${DRONE_COMMIT_SHA} \
		-f Dockerfile .

.PHONY: image-push
push:
	docker push $(PUSHURL)

.PHONY: develop
develop:
	bundle exec jekyll serve . --incremental

.PHONY: preview
preview: assets
	docker run \
		--rm \
		--net host \
		-v $(PWD):/workdir \
		-w /workdir \
		registry.hkoerber.de/hugo:f216de6b127620641bcaf1d28fe16bf1ea2db884 \
		/app/bin/hugo serve \
			--watch \
			--buildDrafts
