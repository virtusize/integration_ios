#!/bin/bash

cd VirtusizeCore

# Remove the old /archives folder
rm -rf archives

# iOS Simulators
xcodebuild -quiet archive \
    -scheme VirtusizeCore \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "archives/VirtusizeCore-iOS-simulator.xcarchive" \
    -sdk iphonesimulator \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES


# iOS Devices
xcodebuild -quiet archive \
    -scheme VirtusizeCore \
    -archivePath "archives/VirtusizeCore-iOS.xcarchive" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES


# Build VirtusizeAuth.xcframework
xcodebuild -create-xcframework \
    -framework "archives/VirtusizeCore-iOS.xcarchive/Products/Library/Frameworks/VirtusizeCore.framework" \
    -framework "archives/VirtusizeCore-iOS-simulator.xcarchive/Products/Library/Frameworks/VirtusizeCore.framework" \
    -output "archives/VirtusizeCore.xcframework"
