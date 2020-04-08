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

	xcodebuild -workspace Virtusize.xcworkspace -scheme Virtusize -destination 'platform=iOS Simulator,name=iPhone 8,OS=13.4' clean build


test:

	xcodebuild -workspace Virtusize.xcworkspace -scheme Virtusize -destination 'platform=iOS Simulator,name=iPhone 8,OS=13.4' clean build test


clean:

	rm -rf .build/


help:

	@echo "$$HELP_MESSAGE"
