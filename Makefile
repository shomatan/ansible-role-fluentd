
DOCKER_IMAGE_NAME=fluentd-test-image
DOCKER_CONTAINER_NAME=fluentd-test
PLAYBOOK_CMD=ansible-playbook fluentd/tests/test.yml -i fluentd/tests/inventory

.PHONY: build
build:
	docker build ./tests -t $(DOCKER_IMAGE_NAME)

.PHONY: run-container
run-container: build
	-docker run -d -v ${PWD}:/test/fluentd \
		--name $(DOCKER_CONTAINER_NAME) \
		--privileged $(DOCKER_IMAGE_NAME) \
		/sbin/init

.PHONY: check
check: run-container
	docker exec -it $(DOCKER_CONTAINER_NAME) $(PLAYBOOK_CMD) --syntax-check

.PHONY: test
test: check
	docker exec -it $(DOCKER_CONTAINER_NAME) $(PLAYBOOK_CMD)

.PHONY: clean
clean:
	-@docker rm -f $(DOCKER_CONTAINER_NAME)

.PHONY: destroy
destroy: clean
	-@docker rmi -f $(DOCKER_IMAGE_NAME)