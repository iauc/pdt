# vim: set noexpandtab fo-=t:
# https://www.gnu.org/software/make/manual/make.html
.PHONY: default
default:

########################################################################
# boiler plate
########################################################################
SHELL=bash

ifneq ($(filter all vars,$(VERBOSE)),)
dump_var=$(info var $(1)=$($(1)))
dump_vars=$(foreach var,$(1),$(call dump_var,$(var)))
else
dump_var=
dump_vars=
endif

ifneq ($(filter all targets,$(VERBOSE)),)
__ORIGINAL_SHELL:=$(SHELL)
SHELL=$(warning Building $@$(if $<, (from $<))$(if $?, ($? newer)))$(TIME) $(__ORIGINAL_SHELL)
endif

define __newline


endef

########################################################################
# variables ...
########################################################################
tools_dir=local-tools
cache_dir=$(HOME)/.cache
outputs_dir=outputs
GOPATH:=$(shell type go >/dev/null 2>&1 && go env GOPATH)
export PATH:=$(if $(GOPATH),$(GOPATH)/bin:,)$(PATH)
export GOFLAGS:=

########################################################################
# targets ...
########################################################################

.PHONY: all
default: all
all: validate

.PHONY: clean
clean: clean-$(outputs_dir)/

.PHONY: distclean
distclean: clean-$(tools_dir)/


modd_bin=$(tools_dir)/modd
modd_version=0.8
$(modd_bin): | $(tools_dir)/ $(cache_dir)/
	cd $(cache_dir) && wget -c https://github.com/cortesi/modd/releases/download/v$(modd_version)/modd-$(modd_version)-linux64.tgz
	tar -zxvf $(cache_dir)/modd-0.8-linux64.tgz --strip-components=1 -C $(tools_dir)

.PHONY: toolchain
toolchain: $(modd_bin)
	cd ~/ && go get $(if $(filter all commands,$(VERBOSE)),-v) $(go_get_flags) \
		github.com/golangci/golangci-lint/cmd/golangci-lint@v1.39.0 \
		&& true

.PHONY: toolchain-update
toolchain-update: go_get_flags+=-u
toolchain-update: toolchain

.PHONY: validate-static
validate-static:
	golangci-lint run $(if $(filter all commands,$(VERBOSE)),-v) ./...

.PHONY: validate-fix
validate-fix:
	golangci-lint run $(if $(filter all commands,$(VERBOSE)),-v) --fix ./...

.PHONY: test
test:
	go test -cover -race \
		-coverprofile=coverage.out -covermode=atomic \
		$(if $(filter all commands,$(VERBOSE)),-v) \
		$(if $(gotest_files),$(gotest_files),./...) \
		$(gotest_args) \

.PHONY: view-coverage
view-coverage:
	go tool cover -html=coverage.out

.PHONY: validate-dynamic
validate-dynamic: test

.PHONY: validate
validate: validate-static validate-dynamic

.PHONY: watch
watch: $(modd_bin)
	./$(modd_bin) --debug --notify --file modd.conf

.PHONY: publish-coverage
publish-coverage: test
	bash <(curl -s https://codecov.io/bash)

help:
	@printf "########################################################################\n"
	@printf "TARGETS:\n"
	@printf "########################################################################\n"
	@printf "%-32s%s\n" "help" "Show this output ..."
	@printf "%-32s%s\n" "all" "Build all outputs (default)"
	@printf "%-32s%s\n" "toolchain" "Install toolchain"
	@printf "%-32s%s\n" "validate" "Validate everything"
	@printf "%-32s%s\n" "validate-fix" "Fix auto-fixable validation errors"
	@printf "%-32s%s\n" "generate" "Generate code"
	@printf "%-32s%s\n" "build" "Build everything"
	@printf "%-32s%s\n" "install" "Install everything"
	@printf "%-32s%s\n" "run-help" "Runs every command with --help"
	@printf "%-32s%s\n" "run" "Runs the main command"
	@printf "%-32s%s\n" "distclean" "Cleans all things that should not be checked in"
	@printf "%-32s%s\n" "build-oci" "Build the OCI Image"
	@printf "%-32s%s\n" "run-oci" "Run the OCI Image"
	@printf "%-32s%s\n" "validate-oci" "Validate the OCI Image"
	@printf "########################################################################\n"
	@printf "VARIABLES:\n"
	@printf "########################################################################\n"
	@printf "%-32s%s\n" "VERBOSE" "Sets verbosity for specific aspects." \
						"" "Space seperated." \
						"" "Valid values: all, vars, commands, targets"

########################################################################
# useful ...
########################################################################
## force ...
.PHONY: .FORCE
.FORCE:
$(force_targets): .FORCE

## dirs ...
.PRECIOUS: %/
%/:
	mkdir -vp $(@)

.PHONY: clean-%/
clean-%/:
	@{ test -d $(*) && { set -x; rm -vr $(*); set +x; } } || echo "directory $(*) does not exist ... nothing to clean"
