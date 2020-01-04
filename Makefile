#####################################################
# This file has been generated from the Dev Toolkit #
#####################################################

EXEC=./docker/scripts/exec.sh

.DEFAULT_GOAL := help
.PHONY: help

help:
		@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*3458)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-25s\033[0m %s\n", 34581, 34582}' | sed -e 's/\[32m##/[33m/'

##---------------------------------------------------------------------------
## Docker
##---------------------------------------------------------------------------

init: ## Init project
init: env up install

up: ## Deploy the stack
	$(EXEC) deploy
	$(EXEC) info

down: ## Remove the stack
	$(EXEC) remove

info: ## Display container ID
	$(EXEC) info

exec: ## Go to container
	$(EXEC) exec

env: ## Set .env file
	$(EXEC) envs

