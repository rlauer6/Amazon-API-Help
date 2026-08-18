BOTOCORE_PATH  := $(BUILD_DIR)/botocore
BOTOCORE_STATE := $(BUILD_DIR)/.botocore.state
BOTOCORE_REPO  := https://github.com/boto/botocore.git
BOTOCORE_BASE  := $(BOTOCORE_PATH)/botocore/data

$(BOTOCORE_STATE): | $(BOTCORE_PATH)
	$(NO_ECHO)local=$$(cd $(BOTOCORE_PATH) && git rev-parse HEAD); \
	if [[ ! -e $@ ]] || [[ "$$local" != "$$(cat $@)" ]]; then echo "$$local" > $@; fi

# The directory target handles the initial clone
$(BOTOCORE_PATH):
	$(NO_ECHO)botocore_env=$$(mktemp); trap 'rm -f $$botcore_env' EXIT; \
	perl -MAmazon::API::BuildInfo -e 'print sprintf qq{BOTOCORE_VERSION=%s\nBOTOCORE_COMMIT=%s\n}, Amazon::API::BuildInfo->botocore_version();' > $$botocore_env; \
	source $$botocore_env; \
	mkdir -p $@; \
	git clone --branch $$BOTOCORE_VERSION --depth=1 $(BOTOCORE_REPO) $@ || true

# note: METADATA will be --no-metadata for Amazon-API
botocore-metadata.api module-names.json &: \
    $(BOTOCORE_STATE) \
    $(CREATE_MODULE_NAMES) | $(BOTOCORE_PATH)
	$(NO_ECHO)PERL5LIB=$(PERL5LIBDIR):$(BUILD_DIR)/local/lib/perl5 \
	  $(AMAZON_API) -b $(BOTOCORE_PATH) create-module-names
