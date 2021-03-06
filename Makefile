OS := $(shell uname)

DEV_ROCKS = "busted 2.0.rc12" "luacheck 0.20.0" "lua-llthreads2 0.1.4"
BUSTED_ARGS ?= -v
TEST_CMD ?= bin/busted $(BUSTED_ARGS)

ifeq ($(OS), Darwin)
    OPENSSL_DIR ?= /usr/local/opt/openssl
    TEST_CMD = /usr/local/bin/busted $(BUSTED_ARGS)
else
    OPENSSL_DIR ?= /usr
endif

install:
	@luarocks make OPENSSL_DIR=$(OPENSSL_DIR) CRYPTO_DIR=$(OPENSSL_DIR)
dev:
	-@luarocks remove kong
	@luarocks make OPENSSL_DIR=$(OPENSSL_DIR) CRYPTO_DIR=$(OPENSSL_DIR)
	@for rock in $(DEV_ROCKS) ; do \
	  if luarocks list --porcelain $$rock | grep -q "installed" ; then \
	    echo $$rock already installed, skipping ; \
	  else \
	    echo $$rock not found, installing via luarocks... ; \
	    luarocks install $$rock ; \
	  fi \
	done;
lint:
	@luacheck -q .
test:
	@$(TEST_CMD) spec/01-unit
upload:
	luarocks upload kong-plugin-rbac-*.rockspec
	rm kong-plugin-rbac-*.src.rock
