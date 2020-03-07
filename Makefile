APP_DIR=app
OVERLAY_DIR=overlay
APPS:=$(wildcard $(APP_DIR)/*)
OVERLAYS:=$(wildcard $(OVERLAY_DIR)/*)
APP_TESTS:=$(addsuffix /diff.txt,$(addprefix test/,$(APPS)))
OVERLAY_TESTS:=$(sort $(addsuffix /diff.txt,$(addprefix test/,$(OVERLAYS))))

YTT_REF=master

M = $(shell printf "\033[34;1m▶\033[0m")

.DEFAULT:
all: tools test

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
test-app: $(APP_TESTS)

.PHONY:
test-overlay: $(OVERLAY_TESTS)

.PHONY:
clean: ; $(info $(M) Cleaning...)
	@set -o errexit; \
	find . -type f -name result.txt -exec rm {} \;; \
	find . -type f -name diff.txt -exec rm {} \;

test/%/expected.txt:
	@echo "ERROR: Missing $@"; \
	false

test/%/diff.txt: test/%/result.txt test/%/expected.txt ; $(info $(M) Running $(@:%/diff.txt=%))
	@set -o errexit; \
	TEST_DIR=$(@:%/diff.txt=%); \
	diff -u $${TEST_DIR}/expected.txt $${TEST_DIR}/result.txt | tee $${TEST_DIR}/diff.txt; \
	if test "$$(stat -c%s $${TEST_DIR}/diff.txt)" -gt 0; then \
		rm $${TEST_DIR}/diff.txt; \
	    false; \
	fi

.SECONDARY:
test/app/%/result.txt:
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%); \
	mkdir -p $${TEST_DIR}; \
	APP_DIR=$${TEST_DIR#test/}; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    ./bin/ytt --ignore-unknown-comments -f $${APP_DIR} >$${TEST_DIR}/result.txt; \
	fi; \
	cat $${TEST_DIR}/result.txt | ./bin/kubeyaml

.SECONDARY:
test/overlay/%/result.txt:
	@set -o errexit; \
	TEST_DIR=$(@:%/result.txt=%) ; \
	mkdir -p $${TEST_DIR}; \
	OVERLAY_DIR=$${TEST_DIR#test/} ; \
	if test -f $${TEST_DIR}/run.sh; then \
	    bash $${TEST_DIR}/run.sh >$${TEST_DIR}/result.txt; \
	else \
	    test -f $${TEST_DIR}/test.yaml; \
	    ./bin/ytt --ignore-unknown-comments -f $${TEST_DIR}/test.yaml -f $${OVERLAY_DIR} >$${TEST_DIR}/result.txt; \
	fi

bin:
	@mkdir -p bin

.PHONY:
docker: Dockerfile ; $(info $(M) Building tools...)
	@docker build --tag tools --build-arg YTT_REF=$(YTT_REF) --file docker/Dockerfile docker

.PHONY:
tools: ytt kapp kind kubeyaml

.PHONY:
ytt: bin/ytt

bin/ytt: bin ; $(info $(M) Installing ytt...)
	@set -o errexit; \
	curl -s https://api.github.com/repos/k14s/ytt/releases/latest | \
	    jq --raw-output '.assets[] | select(.name == "ytt-linux-amd64") | .browser_download_url' | \
	    xargs curl -sLfo ./bin/ytt; \
	chmod +x ./bin/ytt

.PHONY:
kapp: bin/kapp

bin/kapp: bin ; $(info $(M) Installing kapp...)
	@set -o errexit; \
	curl -s https://api.github.com/repos/k14s/kapp/releases/latest | \
	    jq --raw-output '.assets[] | select(.name == "kapp-linux-amd64") | .browser_download_url' | \
	    xargs curl -sLfo ./bin/kapp; \
	chmod +x ./bin/kapp

.PHONY:
kind: bin/kind

bin/kind: bin ; $(info $(M) Installing kind...)
	@set -o errexit; \
	curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | \
    		jq --raw-output '.assets[] | select(.name == "kind-linux-amd64") | .browser_download_url' | \
    		xargs curl -sLfo ./bin/kind; \
	chmod +x ./bin/kind

.PHONY:
kubeyaml: bin/kubeyaml

bin/kubeyaml: bin docker ; $(info $(M) Installing kubeyaml...)
	@set -o errexit; \
	docker create --name tools tools; \
	docker cp tools:/kubeyaml bin/; \
	docker rm tools
