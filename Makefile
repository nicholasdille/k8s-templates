APP_DIR=app
OVERLAY_DIR=overlay
APPS:=$(wildcard $(APP_DIR)/*)
OVERLAYS:=$(wildcard $(OVERLAY_DIR)/*)
APP_TEST_RESULTS:=$(addsuffix /result.txt,$(addprefix test/,$(APPS)))
OVERLAY_TEST_RESULTS:=$(sort $(addsuffix /result.txt,$(addprefix test/,$(OVERLAYS))))

M = $(shell printf "\033[34;1m▶\033[0m")

.PHONY:
debug:
	@echo APP_DIR=$(APP_DIR) OVERLAY_DIR=$(OVERLAY_DIR); \
	echo APPS=$(APPS); \
	echo OVERLAYS=$(OVERLAYS); \
	echo APP_TEST_RESULTS=$(APP_TEST_RESULTS); \
	echo OVERLAY_TEST_RESULTS=$(OVERLAY_TEST_RESULTS)

.PHONY:
test: $(APP_TEST_RESULTS) $(OVERLAY_TEST_RESULTS)

.PHONY:
clean: ; $(info $(M) Cleaning...)
	@find . -type f -name result.txt -exec rm {} \;

test/app/%/result.txt: ; $(info $(M) Testing $@...)
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%) ; \
	APP_DIR=$${TEST_DIR#test/} ; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    ytt -f $${APP_DIR} >$${TEST_DIR}/result.txt; \
	fi; \
	diff -u $${TEST_DIR}/expected.txt $${TEST_DIR}/result.txt

test/overlay/%/result.txt: ; $(info $(M) Testing $@...)
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%) ; \
	OVERLAY_DIR=$${TEST_DIR#test/} ; \
	test -f $${TEST_DIR}/test.yaml; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    ytt -f $${TEST_DIR}/test.yaml -f $${OVERLAY_DIR} >$${TEST_DIR}/result.txt; \
	fi; \
	diff -u $${TEST_DIR}/expected.txt $${TEST_DIR}/result.txt
