#
# The binaries you need installed globally are node, npm and nw
#

# NB: Create a file named `debug_repository.conf' in the root of the
# project that contains a string - the path to a testing git
# repository. The `run' and `debug' targets will use this path or the
# CWD if not set.

project_name := pharyngitis
sources := $(shell find src -iname '*.iced')
# extra_sources is everything except .iced and .js and hidded files in the scr dir
extra_sources := $(shell find src ! -path '*node_modules*' -a -type f -a ! -iname '*.iced' -a ! -name "\.*")
test_sources := $(shell find test -iname '*.iced')
dist_sources := node_modules

compiled = $(sources:.iced=.js)
test_compiled = $(test_sources:.iced=.js)

distdir := .dist

nw_package := $(project_name).nw

iced := node_modules/.bin/iced
mocha := node_modules/.bin/mocha

# set the path to the debug project
ifneq ($(wildcard debug_repository.conf),)  # file exists
  phrg_debug_project := $(shell cat debug_repository.conf)
endif
ifeq ($(phrg_debug_project),) # var still empty
  phrg_debug_project = $(shell pwd)
endif


all: node_modules dist

test: $(test_compiled)
	@echo "(target) running tests..."
	@$(mocha)

dist: $(nw_package)

test/%.js: test/%.iced src/%.js
	@echo "(compile) test: $<"
	@$(iced) -c $<

src/%.js: src/%.iced
	@echo "(compile) source: $<"
	@$(iced) -c $<

$(nw_package): node_modules  src/package.json $(compiled) $(dist_sources) $(extra_sources)
	@echo "(target) generating distribution $(nw_package)"
	@rm -rf $(nw_package) $(distdir) && mkdir -p $(distdir)
	@cp -r $(dist_sources) $(distdir)
	@for f in $(compiled) $(extra_sources); do \
	  target_path=$(distdir)/`echo $$f | sed -e 's%src/%%'`; \
	  mkdir -p `dirname $$target_path`; \
	  cp -f $$f $$target_path; \
	done
	@cd $(distdir) && zip -qr ../$(nw_package) ./

clean:
	@echo "(target) cleaning..."
	@rm -rf $(nw_package) $(compiled) $(test_compiled) $(distdir)

node_modules: package.json
	@echo "(target) updating node modules..."
	@npm install && touch $@

debug:
	@echo "(debug) running with git repo set to: $(phrg_debug_project) ..."
	@nw src $(phrg_debug_project)

run: dist
	@echo "(target) running with git repo set to: $(phrg_debug_project) ..."
	nw $(nw_package) $(phrg_debug_project)

.PHONY: clean test run
