#!/bin/bash

./bin/ytt -f app/drone/server -f app/drone/agent-dind -f app/drone/server-volume
