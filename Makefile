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
		-destination "platform=iOS Simulator,name=iPhone 8,OS=latest"

test:

	xcodebuild clean test \
		-quiet \
		-workspace "Virtusize.xcworkspace" \
		-scheme "VirtusizeTests" \
		-sdk "iphonesimulator" \
		-destination "platform=iOS Simulator,name=iPhone 8,OS=latest"

clean:

	rm -rf .build/


help:

	@echo "$$HELP_MESSAGE"
