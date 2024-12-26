.init.keep: init
init: init.sh
	bash init.sh
	touch .init.keep

up: init
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

clean:
	rm -f *.keep *.env *.yml

help:
	@echo "Supported build targets:"
	@echo " init: pulls firefly III compose sources and minimally configures them"
	@echo " up: ..."
	@echo " down: ..."
	@echo " logs: ..."
	@echo " clean: removes all local container config and env files"
	@echo " help: prints this help menu"
