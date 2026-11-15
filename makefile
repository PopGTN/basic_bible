# Makefile for deploying the Flutter web app to GitHub Pages

OUTPUT ?= Basic_Bible_WEB
GITHUB_USER := PopGTN
GITHUB_REPO := https://github.com/$(GITHUB_USER)/$(OUTPUT).git
BUILD_VERSION := $(shell grep '^version:' pubspec.yaml | awk '{print $$2}')
CUSTOM_DOMAIN ?= bible.joshuamc.ca

ifeq ($(strip $(CUSTOM_DOMAIN)),)
BASE_HREF := /$(OUTPUT)/
else
BASE_HREF := /
endif

deploy:
	@echo "Cleaning previous build artifacts..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Checking required web SQLite binaries..."
	@test -f web/sqlite3.wasm && test -f web/sqflite_sw.js || \
	(echo "Missing web/sqlite3.wasm or web/sqflite_sw.js. Run: dart run sqflite_common_ffi_web:setup"; exit 1)

	@echo "Building for GitHub Pages with base href $(BASE_HREF)..."
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Preparing GitHub Pages artifacts..."
	touch build/web/.nojekyll
	cp build/web/index.html build/web/404.html
	@if [ -n "$(CUSTOM_DOMAIN)" ]; then \
		echo "$(CUSTOM_DOMAIN)" > build/web/CNAME; \
		echo "Configured custom domain: $(CUSTOM_DOMAIN)"; \
	fi

	@echo "Deploying build/web to $(GITHUB_REPO)..."
	cd build/web && \
	git init && \
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && \
	git branch -M main && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u -f origin main

	@echo "Finished deploy: $(GITHUB_REPO)"
	@echo "Flutter web URL: https://$(GITHUB_USER).github.io/$(OUTPUT)/"

.PHONY: deploy
