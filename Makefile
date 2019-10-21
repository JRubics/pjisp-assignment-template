RST_MAINFILE = assignment_all.rst


# Please don't touch the following settings
DIR_NAME := $(shell basename "$(CURDIR)")
ASSIGNMENT_PDF := "assignment $(DIR_NAME).pdf"
ASSIGNMENT_ARCHIVE := "assignment_packed_for_students $(DIR_NAME).tar.gz"
SMOKE_TEST_VERSION := $(shell pipenv lock -r | grep smoke-test | awk -F "==" '{ print $$NF }')
SMOKE_TEST_PEX_URL := https://github.com/petarmaric/smoke_test/releases/download/$(SMOKE_TEST_VERSION)/smoke_test-$(SMOKE_TEST_VERSION).pex


.PHONY: help
help: ## Display this help message
	@echo "Usage: make \033[36m[TARGET]\033[0m...\n\nTargets:"
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { \
		printf "  \033[36m%-16s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)


smoke_test.pex:
	wget $(SMOKE_TEST_PEX_URL) -O $@ || rm -f $@
	chmod +x $@

.PHONY: test-solution
test-solution: smoke_test.pex ## Test your assignment solution
	./$< assignment_solution.c


.PHONY: assignment-clean
assignment-clean: ## Remove all generated student assignment files
	rm -f $(ASSIGNMENT_PDF) $(ASSIGNMENT_ARCHIVE)

.PHONY: assignment-build
assignment-build: ## Build the student assignment PDF
	rst2pdf $(RST_MAINFILE) -o $(ASSIGNMENT_PDF) -s a4,freetype-serif

.PHONY: assignment-view
assignment-view: assignment-build ## View the student assignment PDF
	xdg-open $(ASSIGNMENT_PDF)

.PHONY: assignment-pack
assignment-pack: test-solution assignment-build ## Pack the student assignment
	tar -czf $(ASSIGNMENT_ARCHIVE) smoke_test.pex fixtures/ assignment.c $(ASSIGNMENT_PDF)

.PHONY: assignment
assignment: assignment-clean assignment-pack assignment-view ## Build, view and pack the student assignment