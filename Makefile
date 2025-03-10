# This file is licensed under the Affero General Public License version 3 or
# later. See the COPYING file.
# @author Bernhard Posselt <dev@bernhard-posselt.com>
# @copyright Bernhard Posselt 2016

# Dependencies:
# * make
# * which
# * npm
# * curl: used if phpunit and composer are not installed to fetch them from the web
# * tar: for building the archive
yarn_install=$(shell which yarn)
app_name=forms

project_dir=$(CURDIR)
build_dir=$(CURDIR)/build
build_tools_dir=$(build_dir)/tools
build_source_dir=$(build_dir)/source
appstore_build_dir=$(build_dir)/artifacts/appstore
appstore_package_name=$(appstore_build_dir)/$(app_name)
nc_cert_dir=$(HOME)/.nextcloud/certificates
composer=$(shell which composer 2> /dev/null)

all: dev-setup appstore

# Dev environment setup
dev-setup: clean-dev npm-init composer

npm-init:
ifeq (,$(yarn_install))
	npm install
else
	yarn
endif

# a copy is fetched from the web
.PHONY: composer
composer:
ifeq (,$(composer))
	@echo "No composer command available, downloading a copy from the web"
	mkdir -p $(build_tools_dir)
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar $(build_tools_dir)
	php $(build_tools_dir)/composer.phar install --prefer-dist
	php $(build_tools_dir)/composer.phar update --prefer-dist
else
	composer install --prefer-dist
	composer update --prefer-dist
endif

# Lint
lint:
	npm run lint

lint-fix:
	npm run lint:fix

# Removes the appstore build and compiled js files
.PHONY: clean
clean:
	rm -rf $(build_dir)
	rm -f js/forms.js
	rm -f js/forms.js.map

clean-dev: clean
	rm -rf node_modules
	rm -rf ./vendor

# Build js
# Installs and updates the composer dependencies. If composer is not installed
build-js-production:
		npm run build

# Builds the source package for the app store, ignores php and js tests
.PHONY: appstore
appstore: clean lint build-js-production
	mkdir -p $(build_source_dir)
	mkdir -p $(appstore_build_dir)
	rsync -a \
	--exclude="ISSUE_TEMPLATE.md" \
	--exclude="*.log" \
	--exclude=".*" \
	--exclude="_*" \
	--exclude="build" \
	--exclude="bower.json" \
	--exclude="composer.*" \
	--exclude="js/.*" \
	--exclude="js/*.log" \
	--exclude="js/bower.json" \
	--exclude="js/karma.*" \
	--exclude="js/node_modules" \
	--exclude="js/package.json" \
	--exclude="js/protractor.*" \
	--exclude="js/test" \
	--exclude="js/tests" \
	--exclude="karma.*" \
	--exclude="l10n/no-php" \
	--exclude="Makefile" \
	--exclude="node_modules" \
	--exclude="package*" \
	--exclude="phpunit*xml" \
	--exclude="protractor.*" \
	--exclude="screenshots" \
	--exclude="src" \
	--exclude="tests" \
	--exclude="vendor" \
	--exclude="webpack.*" \
	$(project_dir)/ $(build_source_dir)/$(app_name)
	tar -czf $(appstore_package_name).tar.gz \
	   --directory="$(build_source_dir)" $(app_name)
	@if [ -f $(nc_cert_dir)/$(app_name).key ]; then \
		echo "Signing package..."; \
		openssl dgst -sha512 -sign $(nc_cert_dir)/$(app_name).key $(appstore_build_dir)/$(app_name).tar.gz | openssl base64; \
	fi

.PHONY: test
test: composer
	$(CURDIR)/vendor/phpunit/phpunit/phpunit --coverage-clover clover.xml -c phpunit.xml
	$(CURDIR)/vendor/phpunit/phpunit/phpunit -c phpunit.integration.xml
