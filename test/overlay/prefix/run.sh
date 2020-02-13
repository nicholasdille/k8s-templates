#!/bin/bash

ytt -f test/overlay/prefix/ -f overlay/prefix/ -v prefix=foo- -v suffix=-bar
