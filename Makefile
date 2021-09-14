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

	xcodebuild build \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "Virtusize" \
		-destination "platform=iOS Simulator,name=iPhone 8,OS=14.4" \
		clean build

test:

	xcodebuild build \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "Virtusize" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone 8,OS=14.4" \
		clean build test

clean:

	rm -rf .build/


help:

	@echo "$$HELP_MESSAGE"
