BUNDLE_VERSION?=$(shell yq e '.version' porter/nginx-oss/porter.yaml)

.PHONY: build-porter-nginx-oss
build-porter-nginx-oss:
	@mkdir -p porter/nginx-oss/terraform porter/nginx-oss/ansible-playbooks/NGINXOSS
	cp -R infrastructure/loadbalancing/* porter/nginx-oss/terraform/
	cp -R deployments/NGINXOSS/* porter/nginx-oss/ansible-playbooks/NGINXOSS/
	cd porter/nginx-oss && porter build --version $(BUNDLE_VERSION)

.PHONY: publish-porter-nginx-oss
publish-porter-nginx-oss: build-porter-nginx-oss
	cd porter/nginx-oss && porter publish --force

.PHONY: update-porter-yaml-version
update-porter-yaml-version:
	sed -E -i.bck "s/^version: [0-9]+\.[0-9]+\.[0-9]+.*/version: $(BUNDLE_VERSION)/" porter/nginx-oss/porter.yaml
	@rm porter/nginx-oss/porter.yaml.bck

.PHONY: update-porter-docs
update-porter-docs:
	sed -E -i.bck "s/\/nginx-oss:v[0-9]+\.[0-9]+\.[0-9]+.*/\/nginx-oss:v$(BUNDLE_VERSION)/" porter/nginx-oss/README.md
	@rm porter/nginx-oss/README.md.bck
