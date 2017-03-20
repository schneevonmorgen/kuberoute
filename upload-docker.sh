#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mercurial docker gnumake

if hg id -i | grep "\+"; then
    echo repo is dirty
    exit 1
fi

REV=$(hg id -i)
BRANCH=$(hg branch)

make docker_image
docker load < result
docker tag kuberoute:latest "quay.io/schneevonmorgen/kuberoute:$BRANCH-$REV"
docker push "quay.io/schneevonmorgen/kuberoute:$BRANCH-$REV"
