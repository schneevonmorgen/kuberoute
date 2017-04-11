run:
	nix-shell --command 'python3 scripts/kuberoute --config credentials.txt --debug'

update:
	nix-shell -I nix/pkgs.nix nix/update.nix --show-trace

test:
	nix-shell --command './run-tests'

sdist:
	nix-shell --command 'python3 setup.py sdist'

docker_image:
	bash build_docker_image.sh

flake8:
	nix-shell -p python3Packages.flake8 python3 --command 'flake8 src/kuberoute'

.PHONY: run update test replace create delete flake8
