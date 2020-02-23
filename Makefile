APP_DIR=app
OVERLAY_DIR=overlay
APPS:=$(wildcard $(APP_DIR)/*)
OVERLAYS:=$(wildcard $(OVERLAY_DIR)/*)
APP_TEST_RESULTS:=$(addsuffix /result.txt,$(addprefix test/,$(APPS)))
OVERLAY_TEST_RESULTS:=$(sort $(addsuffix /result.txt,$(addprefix test/,$(OVERLAYS))))

YTT_REF=master

M = $(shell printf "\033[34;1m▶\033[0m")

.PHONY:
debug:
	@echo APP_DIR=$(APP_DIR) OVERLAY_DIR=$(OVERLAY_DIR); \
	echo APPS=$(APPS); \
	echo OVERLAYS=$(OVERLAYS); \
	echo APP_TEST_RESULTS=$(APP_TEST_RESULTS); \
	echo OVERLAY_TEST_RESULTS=$(OVERLAY_TEST_RESULTS)

.PHONY:
test: test-app test-overlay

.PHONY:
test-app: $(APP_TEST_RESULTS)

.PHONY:
test-overlay: $(OVERLAY_TEST_RESULTS)

.PHONY:
clean: ; $(info $(M) Cleaning...)
	@find . -type f -name result.txt -exec rm {} \;

test/app/%/result.txt: ; $(info $(M) Testing $@...)
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%) ; \
	mkdir -p $${TEST_DIR}; \
	APP_DIR=$${TEST_DIR#test/} ; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    ./bin/ytt -f $${APP_DIR} >$${TEST_DIR}/result.txt; \
	fi; \
	diff -u $${TEST_DIR}/expected.txt $${TEST_DIR}/result.txt

test/overlay/%/result.txt: ; $(info $(M) Testing $@...)
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%) ; \
	mkdir -p $${TEST_DIR}; \
	OVERLAY_DIR=$${TEST_DIR#test/} ; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    test -f $${TEST_DIR}/test.yaml; \
	    ./bin/ytt -f $${TEST_DIR}/test.yaml -f $${OVERLAY_DIR} >$${TEST_DIR}/result.txt; \
	fi; \
	diff -u $${TEST_DIR}/expected.txt $${TEST_DIR}/result.txt

bin:
	@mkdir -p bin

.PHONY:
ytt: bin/ytt

bin/ytt: bin ; $(info $(M) Installing ytt...)
	@set -o errexit; \
	docker build --tag ytt:$(YTT_REF) --build-arg REF=$(YTT_REF) --file docker/Dockerfile docker; \
	docker create --name ytt_$(YTT_REF) ytt:$(YTT_REF); \
	docker cp ytt_$(YTT_REF):/ytt bin/ytt; \
	docker rm ytt_$(YTT_REF)

.PHONY:
kapp: bin/kapp

bin/kapp: bin ; $(info $(M) Installing kapp...)
	@set -o errexit; \
	curl -s https://api.github.com/repos/k14s/kapp/releases/latest | \
	    jq --raw-output '.assets[] | select(.name == "kapp-linux-amd64") | .browser_download_url' | \
	    xargs curl -sLfo ./bin/kapp; \
	chmod +x ./bin/kapp
