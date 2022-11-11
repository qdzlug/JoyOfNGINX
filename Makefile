.PHONY: build-porter-nginx-oss
build-porter-nginx-oss:
	@mkdir -p porter/nginx-oss/terraform porter/nginx-oss/ansible-playbooks
	cp -R infrastructure/loadbalancing/* porter/nginx-oss/terraform
	cp -R deployments/NGINXOSS/* porter/nginx-oss/ansible-playbooks
	cd porter/nginx-oss && porter build
