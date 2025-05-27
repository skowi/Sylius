phpunit:
	vendor/bin/phpunit

phpspec:
	vendor/bin/phpspec run --ansi --no-interaction -f dot

phpstan:
	vendor/bin/phpstan analyse

behat-cli:
	vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="~@javascript&&@cli&&~@todo" || vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="~@javascript&&@cli&&~@todo" --rerun

behat-non-js:
	vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="~@javascript&&~@cli&&~@todo" || vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="~@javascript&&~@cli&&~@todo" --rerun

behat-js:
	vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="@javascript&&~@cli&&~@todo" || vendor/bin/behat --colors --strict --no-interaction -vvv -f progress --tags="@javascript&&~@cli&&~@todo" --rerun

install:
	composer install --no-interaction --no-scripts

backend:
	bin/console doctrine:database:create --no-interaction
	bin/console sylius:install --no-interaction
	bin/console sylius:fixtures:load default --no-interaction

frontend:
	yarn install --pure-lockfile
	yarn encore production

behat: behat-cli behat-non-js behat-js

init: install backend frontend

ci: init phpstan phpunit phpspec behat

integration: init phpunit behat-cli behat-non-js

static: install phpspec phpstan

# Example execution: make profile url=http://app
profile:
	docker compose exec blackfire blackfire curl -L $(url)

.PHONY: docker-up
docker-up:
	@set -e; \
	PORT=80; \
	if nc -z localhost $$PORT 2>/dev/null; then \
	for P in $$(seq 8080 8099); do \
	if ! nc -z localhost $$P 2>/dev/null; then \
	PORT=$$P; \
	break; \
	fi; \
	done; \
	fi; \
	echo "Starting application on port $$PORT"; \
	APP_PORT=$$PORT docker compose up -d
