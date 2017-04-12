#!/usr/bin/env sh

docker push quay.io/schneevonmorgen/kuberoute:$(git rev-parse HEAD)
