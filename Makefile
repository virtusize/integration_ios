define HELP_MESSAGE
Usage: make [COMMAND]

Commands:
	build  Build the project. (default)
	test   Run the tests.
	clean  Remove the build folder.
	help   Display this help message.
endef

export HELP_MESSAGE


.PHONY : build test clean help


build:

	xcodebuild clean build \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "Virtusize" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=latest"

virtusize-test:

	xcodebuild clean test \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "VirtusizeTests" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.1"

virtusize-core-test:

	xcodebuild clean test \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "VirtusizeCoreTests" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.1"

test: virtusize-test virtusize-core-test

clean:

	rm -rf .build/

lint:

	swiftlint --strict

lint-fix:

	swiftlint --fix --strict

validate-fonts:

	sh ./Scripts/validate_fonts.sh

install-git-hooks:

	chmod +x .githooks/pre-push
	git config --local core.hooksPath .githooks

help:

	@echo "$$HELP_MESSAGE"
