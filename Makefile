SHELL=/bin/bash
.DEFAULT_GOAL := default

.PHONY: install
install:
	@echo "---------------------------"
	@echo "- Installing dependencies -"
	@echo "---------------------------"
	flutter pub get
	pip install pre-commit
	pre-commit install

.PHONY: update
update:
	@echo "-------------------------"
	@echo "- Updating dependencies -"
	@echo "-------------------------"
	flutter pub upgrade

.PHONY: clean
clean:
	@echo "---------------------------"
	@echo "- Cleaning unwanted files -"
	@echo "---------------------------"
	flutter clean

.PHONY: lint
lint:
	@echo "-----------------------------"
	@echo "- Run linters and formaters -"
	@echo "-----------------------------"
	pre-commit run --all-files

.PHONY: test
test:
	@echo "-------------"
	@echo "- Run tests -"
	@echo "-------------"
	flutter test

.PHONY: default
default: lint test

.PHONY: run
run:
	@echo "-----------------------"
	@echo "- Running the project -"
	@echo "-----------------------"
	flutter run

.PHONY: build-web
build-web:
	@echo "-------------------------"
	@echo "- Build web for release -"
	@echo "-------------------------"
	flutter build web --web-renderer html --release

.PHONY: build-apk
build-apk:
	@echo "-------------------------"
	@echo "- Build apk for release -"
	@echo "-------------------------"
	flutter build apk --release

.PHONY: build
build: build-web build-apk

.PHONY: pull
pull:
	@echo "------------------------"
	@echo "- Pulling last changes -"
	@echo "------------------------"
	git checkout main
	git pull

.PHONY: full
full: install pull clean update lint test build
