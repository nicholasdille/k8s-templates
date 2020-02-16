#!/bin/bash

ytt -f test/app/traefik-init-dns/test.yaml -f app/traefik-init-dns/
