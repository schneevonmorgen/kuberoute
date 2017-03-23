run:
	nix-shell --command 'python3 scripts/kuberoute --config credentials.txt'

update:
	nix-shell -I nix/pkgs.nix nix/update.nix --show-trace

test:
	nix-shell --command './run-tests'

sdist:
	nix-shell --command 'python3 setup.py sdist'

docker_image:
	bash build_docker_image.sh

replace:
	gdo kubernetes/secret.yml
	kubectl replace -f kubernetes/service.yml
	kubectl replace -f kubernetes/secret.yml
	kubectl replace -f kubernetes/deployment.yml

create:
	gdo kubernetes/secret.yml
	kubectl create -f kubernetes/service.yml
	kubectl create -f kubernetes/secret.yml
	kubectl create -f kubernetes/deployment.yml


delete:
	gdo kubernetes/secret.yml
	kubectl delete -f kubernetes/service.yml
	kubectl delete -f kubernetes/secret.yml
	kubectl delete -f kubernetes/deployment.yml

flake8:
	nix-shell -I nix/pkgs.nix -p pythonPackages.packages.flake8 p.pkgs.python3 --command 'flake8 src/kuberoute'

.PHONY: run update test replace create delete flake8
