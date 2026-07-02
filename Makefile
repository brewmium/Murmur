CONFIG ?= release

.PHONY: build app run clean

build:
	swift build -c $(CONFIG)

app:
	./scripts/build-app.sh $(CONFIG)

run: app
	open build/Murmur.app

clean:
	rm -rf .build build
