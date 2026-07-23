CONFIG ?= release

.PHONY: build app run deploy clean

build:
	swift build -c $(CONFIG)

app:
	./scripts/build-app.sh $(CONFIG)

run: app
	open build/Murmur.app

deploy:
	./scripts/deploy-app.sh

clean:
	rm -rf .build build
