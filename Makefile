REGISTRY := registry.hkoerber.de
APPNAME := blog
PUSHURL := $(REGISTRY)/$(APPNAME)

RESUME := static/assets/resume/Hannes_Koerber_Resume.pdf
RESUME_HTML := static/assets/resume-html

.PHONY: contrib-resume
contrib-resume:
	$(MAKE) -C contrib/resume resume.pdf

.PHONY: contrib-resume-html
contrib-resume-html:
	$(MAKE) -C contrib/resume html-out/index.html

$(RESUME): contrib-resume
	cp contrib/resume/resume.pdf $(RESUME)

$(RESUME_HTML): contrib-resume-html
	cp -r contrib/resume/html-out static/assets/resume-html

.PHONY: assets
assets: $(RESUME) $(RESUME_HTML)

.PHONY: build
build-production: assets
	git diff-index --quiet HEAD || { echo >&2 "Local changes, refusing to build" ; exit 1 ; }
	docker run \
		--rm \
		--net host \
		-v $(PWD):/workdir \
		-w /workdir \
		registry.hkoerber.de/hugo:f216de6b127620641bcaf1d28fe16bf1ea2db884 \
		/app/bin/hugo \
			--baseURL=https://blog.hkoerber.de/ \
			--cleanDestinationDir \
			--minify \
			--destination ./public/
	sudo chown -R $(shell id -u):$(shell id -g) ./public
	sudo chmod -R o+rX ./public

.PHONY: image
image-production: build-production
	git diff-index --quiet HEAD || { echo >&2 "Local changes, refusing to build" ; exit 1 ; }
	docker build \
	  --file ./Dockerfile.nginx \
	  --tag $(REGISTRY)/$(APPNAME):latest \
	  --tag $(REGISTRY)/$(APPNAME):$(shell git rev-parse HEAD) \
	  .


.PHONY: push-production
push-production: image-production
	docker push $(REGISTRY)/$(APPNAME):latest
	docker push $(REGISTRY)/$(APPNAME):$(shell git rev-parse HEAD)

.PHONY: release
release: push-production

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
