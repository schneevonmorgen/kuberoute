#!/usr/bin/env sh

REV="$(git rev-parse HEAD)"
NAME=quay.io/schneevonmorgen/kuberoute

if git diff --exit-code > /dev/null && \
        git diff --cached --exit-code > /dev/null; then
    nix-build nix/docker.nix -o docker-image \
              --arg image_name "\"${NAME}\"" \
              --arg image_tag "\"${REV}\""
    docker load < docker-image
else
    echo "There are uncommited changes in your work tree, exiting with 1"
    exit 1
fi
