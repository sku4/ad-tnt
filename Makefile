.PHONY: rocks
rocks:
	tarantoolctl rocks install --tree=./.rocks --only-deps .rocks/ad-tnt-scm-3.rockspec

helm-install:
	helm upgrade --install "ad-tnt" .helm --namespace=ad-prod

helm-install-local:
	helm upgrade --install "ad-tnt" .helm \
		--namespace=ad-prod \
		-f ./.helm/values-local.yaml \
		--wait \
		--timeout 300s \
		--atomic \
		--debug

helm-template:
	helm template --name-template="ad-tnt" --namespace=ad-prod -f .helm/values-local.yaml .helm > .helm/helm.txt

helm-package:
	helm package .helm
	mv ad-tnt*.tgz docs/charts
	helm repo index docs/charts --url https://raw.githubusercontent.com/sku4/ad-tnt/refs/heads/master/docs/charts/
