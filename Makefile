define HELP_MESSAGE
Usage: make [COMMAND]

Commands:
  build              Build the project. (default)
  test               Run the tests.
  clean              Remove the build folder.
  validate-fonts     Validate the fonts.
  build-fonts        Build the fonts.
  install-git-hooks  Install the git hooks.
  lint               Run the linter.
  lint-fix           Run the linter and fix the issues.
  help               Display this help message.
endef

export HELP_MESSAGE


.PHONY : build test clean help


build:

	xcodebuild clean build \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "Virtusize" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone 16e,OS=18.6" \
		ENABLE_MODULE_VERIFIER=YES # ensure modules are verified

virtusize-test:

	xcodebuild clean test \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "VirtusizeTests" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone 16e,OS=18.6"

virtusize-core-test:

	xcodebuild clean test \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "VirtusizeCoreTests" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone 16e,OS=18.6" \
		-parallel-testing-enabled NO

test: virtusize-test virtusize-core-test

clean:

	rm -rf .build/

lint:

	swiftlint --strict

lint-fix:

	swiftlint --fix --strict

validate-fonts:

	sh ./Scripts/validate_fonts.sh

build-fonts:

	sh ./Scripts/build_fonts.sh

install-git-hooks:

	chmod +x .githooks/pre-push
	git config --local core.hooksPath .githooks

help:

	@echo "$$HELP_MESSAGE"
