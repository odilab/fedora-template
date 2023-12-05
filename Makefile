default: test_local
act:
	@echo "ACT Smoke Test..."
	act pull_request \
	-s GITHUB_TOKEN="$(gh auth token)" \
	-W .github/workflows/test-pr.yaml
smoke:
	rm -rdf /tmp/init
	rm -rdf /tmp/home
	@docker rmi $(docker images -q --filter=reference="vsc-home*" --format "{{.ID}}") -f  &&\
	rm -rdf /tmp/init &&\
	rm -rdf /tmp/home || true
	docker volume prune -f
	@echo "Local Smoketest..."
	.github/actions/smoke-test/build.sh home
	.github/actions/smoke-test/test.sh home