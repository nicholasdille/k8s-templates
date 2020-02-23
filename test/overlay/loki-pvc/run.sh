#!/bin/bash

./bin/ytt -f app/loki -f overlay/loki-pvc
