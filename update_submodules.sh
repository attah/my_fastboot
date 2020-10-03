#!/usr/bin/env bash
git submodule sync --recursive && git submodule update --init --force --recursive --depth=1
