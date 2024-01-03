# SPDX-License-Identifier: Apache-2.0

PROJECT := template
BASEDIR := $(shell pwd)
BUILDIR := build

VERBOSE ?= 0
V ?= $(VERBOSE)
ifeq ($(V), 0)
	Q = @
else
	Q =
endif
export PROJECT
export BASEDIR
export BUILDIR
export Q

include version.mk

all: build size

build:
	cmake -GNinja -B build
	cmake --build build

.PHONY: confirm
confirm:
	@echo 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## version: print firmware version
.PHONY: version
version:
	$(info $(VERSION_TAG), $(VERSION))

## test: run unit testing
.PHONY: test
test:
	$(Q)$(MAKE) -C tests

## clean
.PHONY: clean
clean: confirm
	$(Q)rm -fr $(BUILDIR)
	$(Q)$(MAKE) -C tests $@

## size: print memory segment size
.PHONY: size
size:
	$(Q)xtensa-esp32s3-elf-size $(BUILDIR)/$(PROJECT).elf

.PHONY: flash
flash: $(BUILDIR)/esp32s3.bin
	$(Q)python $(IDF_PATH)/components/esptool_py/esptool/esptool.py \
		--chip esp32s3 -p $(PORT) -b 921600 \
		--before=default_reset --after=no_reset --no-stub \
		write_flash \
		--flash_mode dio --flash_freq 80m --flash_size keep \
		0x20000 $< \
		0xe000 $(BUILDIR)/partition_table/partition-table.bin \
		0x1d000 $(BUILDIR)/ota_data_initial.bin \

FORCE:
