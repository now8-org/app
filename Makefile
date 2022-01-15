SHELL=/bin/bash
.DEFAULT_GOAL := default

.PHONY: install
install:
	@echo "---------------------------"
	@echo "- Installing dependencies -"
	@echo "---------------------------"
	flutter pub get
	flutter pub global activate dartdoc
	pip install --user pre-commit commitizen
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

.PHONY: build-appbundle
build-appbundle:
	@echo "-------------------------------"
	@echo "- Build appbundle for release -"
	@echo "-------------------------------"
	flutter build appbundle --release

.PHONY: build
build: build-web build-apk build-appbundle

.PHONY: pull
pull:
	@echo "------------------------"
	@echo "- Pulling last changes -"
	@echo "------------------------"
	git checkout main
	git pull

.PHONY: full
full: install pull clean update lint test build


.PHONY: icons
icons:
	@echo "--------------------------------------"
	@echo "- Generate icons from icons/logo.svg -"
	@echo "--------------------------------------"
	inkscape -w 1024 -h 1024 icons/logo.svg -o icons/logo.png
	inkscape -w 1200 -h 1200 icons/logo.svg -o /tmp/1200.png
	flutter pub run flutter_launcher_icons:main
	inkscape -w 32 -h 32 icons/logo.svg -o web/favicon.png
	inkscape -w 192 -h 192 icons/logo.svg -o web/icons/Icon-192.png
	convert icons/logo.png -resize 140x140 -gravity center -background "#104068" -extent 192x192 web/icons/Icon-maskable-192.png
	inkscape -w 512 -h 512 icons/logo.svg -o web/icons/Icon-512.png
	convert icons/logo.png -resize 400x400 -gravity center -background "#104068" -extent 512x512 web/icons/Icon-maskable-512.png

.PHONY: docs
docs:
	@echo "-----------------"
	@echo "- Generate docs -"
	@echo "-----------------"
	flutter pub global run dartdoc:dartdoc
