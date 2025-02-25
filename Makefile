# Conditionally include .env file if not running in CI/CD environment
ifndef GITHUB_ACTIONS
  -include .env
endif

# default env values
APTOS_NETWORK ?= custom
ARTIFACTS_LEVEL ?= sparse
DEFAULT_FUND_AMOUNT ?= 100000000
DEFAULT_FUNDER_PRIVATE_KEY ?= 0x0
DEV_ACCOUNT ?= 0x0133e0a39bdfcf5bbde2b1f4def9f36b2842693345ccc49d6aa6f2ee8c7ccf9a
LIBS_ADDRESS ?= 0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d

# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ===================== PACKAGE AMM ===================== #

compile:
	aptos move compile \
	--save-metadata \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_libs=$(DEV_ACCOUNT)"

test:
	aptos move test \
	--named-addresses "razor_libs=$(DEV_ACCOUNT)" \
	--coverage

publish:
	aptos move deploy-object \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_libs=$(DEV_ACCOUNT)" \
	--address-name razor_libs

upgrade:
	aptos move upgrade-object \
	--address-name razor_libs \
	--included-artifacts ${ARTIFACTS_LEVEL} \
	--named-addresses "razor_libs=$(DEV_ACCOUNT)" \
	--object-address $(LIBS_ADDRESS)

docs:
	aptos move document \
	--named-addresses "razor_libs=$(LIBS_ADDRESS)"
