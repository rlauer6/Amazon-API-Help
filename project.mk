BUILD_DIR           ?= $(shell pwd)
AMAZON_API          := $(shell command -v amzn-api)
PERL5LIBDIR         = $(PERL5LIB)

include botocore.mk

local-module-names.json: | $(BOTOCORE_PATH)
	$(NO_ECHO)module_names=$$(perl -MFile::ShareDir=dist_file -e 'print dist_file(q{Amazon-API}, q{module-names.json});'); \
	cp $$module_names $@; \
	chmod 0644 $@; \
	cp $@ module-names.json

.INTERMEDIATE: local-module-names.json module-names.json botocore-metadata.api

botocore-services.api.gz: local-module-names.json botocore-metadata.api | $(BOTOCORE_PATH)
	$(NO_ECHO)cp botocore-metadata.api $$(basename $@ .gz); \
	gzip -f $$(basename $@ .gz)

DEPS += botocore-services.api.gz LICENSE.botocore NOTICE.botocore NOTICE

.PHONY: install
install: $(TARBALL)
	cpanm -n -v -l $(HOME) $<

.PHONY: uninstall
uninstall:
	cpanm -n -l $(HOME) --uninstall $(MODULE_NAME)

botocore-version.json:
	$(NO_ECHO)botocore_version="$$(perl -MFile::ShareDir=dist_file -e 'print dist_file(q{Amazon-API}, q{botocore-version.json});')"; \
	cp $$botocore_version $@

NOTICE: NOTICE.in botocore-version.json
	$(NO_ECHO)BOTOCORE_VERSION=$$(cat botocore-version.json | perl -MJSON=decode_json -n0e '$$v=decode_json($$_); print "$$v->{version}";'); \
	BOTOCORE_COMMIT=$$(cat botocore-version.json |perl -MJSON=decode_json -n0e '$$v=decode_json($$_); print "$$v->{commit}";'); \
        export BOTOCORE_COMMIT BOTOCORE_VERSION; \
	$(BOOTSTRAPPER) resolve-vars $< > $@

LICENSE.botocore: $(BOTOCORE_PATH)/LICENSE.txt | $(BOTOCORE_PATH)
	$(NO_ECHO)cp $< $@

NOTICE.botocore: $(BOTOCORE_PATH)/NOTICE | $(BOTOCORE_PATH)
	$(NO_ECHO)cp $< $@

CLEANFILES += botocore-services.api.gz NOTICE NOTICE.botocore LICENSE.botocore
