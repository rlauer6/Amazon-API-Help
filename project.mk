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

DEPS += botocore-services.api.gz

.PHONY: install
install: $(TARBALL)
	cpanm -n -v -l $(HOME) $<

.PHONY: uninstall
uninstall:
	cpanm -n -l $(HOME) --uninstall $(MODULE_NAME)

CLEANFILES += botocore-services.api.gz
