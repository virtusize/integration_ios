VS iOS Integration Changes
==========================

Instructions:
Use list notation, and following prefixes:

- Feature - for any new features
- Cleanup - any code removal or non visible maintenance change
- Refactor - code refactoring, keeping same functionality
- Bugfix - when fixing any major bug
- Docs - for any improvement to documentation


## NEXT RELEASE for Version 2.x.x

### Next Release
 - Refactor: Update SNS auth flow to fix an issue when users never returned back to the app after successful authentication
 - Refactor: Move in `VirtusizeAuth` source code into the main repository
 - Deprecate: `VirtusizeAuthentication.setAppBundleId` method is deprecated and removed, `bundleId` is resolved authomatically now.

### 2.7.0
- Feature: Introduce internal logger (see [README/logger](/README.md#optional-confgiure-internal-logger) for configuration)
- Change: `InPageMini` and `InPageStandard` now use `NotoSans` font instead of `NotoSansCJK` for Japanese and Korean languages
- Refactor: Reduce SDK binary size by using minimal-required subset of `NotoSans` fonts
- Feature: Validate fonts support all the localization texts during PR checks

### 2.6.6
- Fix: Inpage text is not appropriate when the size is recommended
- Fix: Inpage text for on-boarding user has 2 patterns at random

### 2.6.5
- Fix: Inpage doesn’t recommend anything after coming back to PDP from Comparison screen
- Fix: Inpage shows different size from that VS widget shows
- Fix: Body data tuning is not saved once closing the widget

### 2.6.4
- Fix: Fix the product image resolution

### 2.6.2
- Feature: Enable configuration for SNS button visibility.

### 2.6.1
- Fix: Fix for Duplicate VirtusizeCore Bundles

### 2.6.0
- Refactor: Update the Virtusize web view URL to the following format: https://static.api.virtusize.jp/a/aoyama/\(version)/sdk-webview.html
- Feature: Add the client sepecifc Virtusize web view URL. The format is as follows: https://static.api.virtusize.jp/a/aoyama/testing/privacy-policy-phase2-vue/sdk-webview.html
- Bugfix: Fix the issue of the web view loading indefinitely 

### 2.5.12
- Fix: Update Virtusize Auth SDK to fix the issue of invalid PrivacyInfo.xcprivacy

### 2.5.11
- Fix: Update Virtusize Auth SDK to fix the issue of missing PrivacyInfo.xcprivacy

### 2.5.10
- Fix: Google Sign In Issue
- Fix: Update Virtusize Auth SDK 

### 2.5.9
- Fix: Update current privacy manifest 

### 2.5.8
- Feature : Added PrivacyInfo file to VirtusizeCore
- Feature : Added PrivacyInfo file to Virtusize
- Docs: Update Readme file to update pod version 

### 2.5.7
- Refactor: Change the get-size endpoint from https://services.virtusize.jp/ds-functions/size-rec/get-size ➝ https://size-recommendation.virtusize.jp/item
- Refactor: Change in request body of VirtusizeGetSizeParams: Remove "modelInfo" key,  in "gender" now getting value from VirtusizeUserBodyProfile
- Refactor: Change in response Model of BodyProfileRecommendedSize
- Refactor: VirtusizeEnvironment enum cases key set to Uppercase 
- Cleanup: Remove Print functions and unnecessary commented code from BodyProfileRecommendedSize, VirtusizeAPIService, VirtusizeAPIRequest
- Docs: Update Readme file to update pod version 

### 2.5.4
- Refactor/Bugfix: Change VirtusizeAuth class name to VirtusizeAuthorization to resolve nested Class archive run time issue
- Cleanup: Update deployment target to 13
- Cleanup: Remove deprecated Method from VirtusizeWebView
- Cleanup: Update VirtusizeCore framework deplyment target to ios 13
- Cleanup: Update VirtusizeAuth POD Version to 1.1.0
- Docs: Update Readme file to update Requirements: iOS version 

### 2.5.3
-  Cleanup: Update VirtusizeAuth POD Version to 1.0.3
-  Docs: Update Readme file to update Requirements: iOS version 

### 2.5.2
-  Cleanup: Update to iOS 12.3 (za)
-  Docs: Update Readme file to update Requirements: iOS version  

### 2.5.1

- Feature: Handle SNS auth for web view apps
- Bugfix: Change back the SDK webview URL

### 2.5.0

- Feature: Perform Virtusize SNS authentication with SFSafariViewController

### 2.4.3

- Bugfix: Fix errors when running `pod spec lint`

### 2.4.2 (Invalid)

- Feature: Release the `VirtusizeCore` module

### 2.4.1

- Bugfix: Use the staging API for staging

### 2.4.0

- Feature: Setup Github Actions for CI/CD

### 2.3.2
- Bugfix: Fix the SNS login issue on Fit Illustrator

### 2.3.1
- Feature: Add the Swift Package Manager support

### 2.3.0

- Feature: Add the MIT license
- Refactor: Change the get-size endpoint from `get-size-new` to `get-size`
- Refactor: Remove the `Proxima Nova` font and use the system font
- Refactor: Improve the integration flow 
- Bugfix: Prevent from updating the selected user product ID when the event `user-added-product` is fired

### 2.2.5
- Bugfix: Handle the `user-deleted-product` event from the Virtusize webview

### 2.2.4
- Feature: The Flutter SDK support
- Bugfix: Fix the isValid function in SizeComparisonRecommendedSize.swift

### 2.2.3
- Feature: Enable SNS buttons in the Virtusize webview

### 2.2.2
- Bugfix: Fix a crash related to forcing unwrap an optional value

### 2.2.1
- Feature: Fix SNS Login on the web version of Virtusize integration through the SDK

### 2.1.6
- Bugfix: Fix a crash related to com.apple.root.default-qos
- Bugfix: Fix InPage loading the wrong product issue when there are multiple product pages opened in the navigation stack of a mobile app

### 2.1.5
- Bugfix: Adjust the shadow of InPage

### 2.1.4
- Bugfix: Ensure InPage displays the correct message
- Bugfix: Ensure the image assets from the resource bundle to be displayed on InPage

### 2.1.3
- Feature: Enable font size changes of InPage 
- Bugfix: Ensure InPage displays the correct message when a user is logged out

### 2.1.2
- Feature: Ensure dismissing the Virtusize page by the SDK

### 2.1.1
- Bugfix: Ensure localization resources and font files are in Virtusize.framework

### 2.1.0
- Feature: InPage integration

### 2.0.5
- Feature: Add Korean localization
- Feature: Add Teal as one of the default styles for VirtusizeButton

### 2.0.4
- Feature:  Make the SDK assets accessible to iOS apps

### 2.0.3
- Feature: Enable the debugging info about product data check

### 2.0.2
- Feature: Update to the new event API URL
- Docs - Update README on how to set up the user ID

### 2.0.1
- Bugfix: Fix the Order API error

### 2.0.0
- Feature: A new version of the integration

## NEXT RELEASE for Version 1.x.x

### 1.3.2

- Bugfix: Fix the null regoin value for the Order API

### 1.3.1

- Bugfix: Fix hyperlinks on the side menu.
- Bugfix: Ensure sending product image info to the server is working.
- Feature: Add unit testing for network code

### 1.3.0

- Feature: The Order API
- Docs: Update documentation to the README.

### 1.2.0

- Feature: Dispatch Notification during Product Data Check. (za)

### 1.1.0

- Cleanup: Update to iOS 10.3, swift 5.0. (za) 

### 1.0.1

- Bugfix: Removed `.swift-version` and added `swift_version` key to PodSpec. (za)

### 1.0.0

- Refactor: Rename resources prefixing public entities with Virtusize. (za)
- Refactor: Separate data processing from view logic. (za)
- Refactor: Prefer Enum and model Struct rather than String and Dictionary. (za)
- Refactor: Align code to SwiftLint requirements. (za)
- Docs: Update documentation and roadmap. (za)
- Cleanup: Add support for SwiftLint. (za)
- Cleanup: Update to iOS 10.0, swift 4.2. (za) 

### 0.2.3

- Bugfix: Ensure Media.xcassets is linked to the pod. (za)

### 0.2.2

- Bugfix: Ensure Splashview is closed on any user-opened-panel-* event. (za)

### 0.2.1

- Bugfix: Replace activity indicator deprecated init. (za)

### 0.2.0

- Feature: Add error reporting method to delegate protocol. (za)
- Feature: Add closable splash view with activity indicator. (za)
- Refactor: Reduce complexity of the view controller. (za)
- Feature: Add branding to the Example project. (za)
- Docs: Add setup steps to the README. (za)
- Docs: Add roadmap for features and enhancements. (za) 

### 0.1.4

- Bugfix: Fixed Int Overflow on 32-bit architecture when casting Date. (za)

### 0.1.3

- Bugfix: Fixed layout overlap on iOS pre 11. (ab/za)

### 0.1.2

- Bugfix: Send userId in widget URL. (ab)

### 0.1.1

- Bugfix: Updated key names in events. (ab)
- Bugfix: Send event once product is checked. (ab)

### 0.1.0

- Feature: Initial version. (ab)
