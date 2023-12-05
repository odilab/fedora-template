default: test_local
act:
	@echo "ACT Smoke Test..."
	act pull_request \
	-s GITHUB_TOKEN="$(gh auth token)" \
	-W .github/workflows/test-pr.yaml
smoke:
	rm -rdf /tmp/ansible  || true
	@docker rmi $(docker images -q --filter=reference="vsc-*" --format "{{.ID}}") -f  &&\
	rm -rdf /tmp/ansible || true
	docker volume prune -f
	@echo "Local Smoketest..."
	.github/actions/smoke-test/build.sh ansible
	.github/actions/smoke-test/test.sh ansible