.PHONY: feedback-loop run-poller run-redis get-config

.DEFAULT_GOAL = help

## Use stack to continuously rebuild/run the demo web service
feedback-loop:
	@stack install :json-poll-and-set-redis --file-watch --exec='json-poll-and-set-redis'

run-poller:
	@json-poll-and-set-redis

## Use docker to run redis
run-redis:
	@docker run -d --name=redis --net=host -p 127.0.0.1:6379:6379 redis:alpine

## Use redis-cli to retrieve the current value of our config key
get-config:
	@docker exec -it redis redis-cli GET json_response

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
