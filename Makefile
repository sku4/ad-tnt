.PHONY: rocks
rocks:
	tarantoolctl rocks install --tree=./.rocks --only-deps .rocks/ad-tnt-scm-3.rockspec

helm-install:
	helm upgrade --install "ad-tnt" .helm --namespace=ad-prod

helm-install-local:
	helm upgrade --install "ad-tnt" .helm \
		--namespace=ad-prod \
		-f ./.helm/values-local.yaml

helm-template:
	helm template --name-template="ad-tnt" --namespace=ad-prod -f .helm/values-local.yaml .helm > .helm/helm.txt
