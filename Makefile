
DOCKER_IMAGE_NAME=fluentd-test-image
DOCKER_CONTAINER_NAME=fluentd-test
#PLAYBOOK_CMD=

check:
	ansible-playbook tests/test.yml -i tests/inventory --syntax-check

.PHONY: build
build:
	docker build ./tests -t $(DOCKER_IMAGE_NAME)

.PHONY: run
run: build
	-docker run -d -v ${PWD}:/test/fluentd \
		--name $(DOCKER_CONTAINER_NAME) \
		--privileged $(DOCKER_IMAGE_NAME) \
		/sbin/init

.PHONY: clean
clean:
	-@docker rm -f $(DOCKER_CONTAINER_NAME)

.PHONY: test
test:
	make run && \
	docker exec -it $(DOCKER_CONTAINER_NAME) \
		ansible-playbook fluentd/tests/test.yml -i fluentd/tests/inventory	