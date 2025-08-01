# Virtusize iOS Integration

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Virtusize.svg)](https://cocoapods.org/pods/Virtusize)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Virtusize.svg?style=flat)](https://developers.virtusize.com/native-ios/index.html)
[![Docs](https://img.shields.io/badge/docs--brightgreen.svg)](https://developers.virtusize.com/native-ios/index.html)
[![Twitter](https://img.shields.io/badge/twitter-@virtusize-blue.svg?style=flat)](http://twitter.com/virtusize)

[日本語](README-JP.md)

Virtusize helps retailers to illustrate the size and fit of clothing, shoes and bags online, by letting customers compare the
measurements of an item they want to buy (on a retailer's product page) with an item that they already own (a reference item).
This is done by comparing the silhouettes of the retailer's product with the silhouette of the customer's reference Item.
Virtusize is a widget which opens when clicking on the Virtusize button, which is located next to the size selection on the product page.

Read more about Virtusize at https://www.virtusize.com

You need a unique API key and an Admin account, only available to Virtusize customers. [Contact our sales team](mailto:sales@virtusize.com) to become a customer.

> This is the integration script for native iOS devices only. For web integration, refer to the developer documentation on https://developers.virtusize.com

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
  - [Swift Package Manager](#swift-package-manager)
  - [Carthage](#carthage)
- [Setup](#setup)
  - [Initialization](#1-initialization)
  - [Load Product with Virtusize SDK](#2-load-product-with-virtusize-sdk)
  - [Enable SNS authentication](#3-enable-sns-authentication)
  - [Implement VirtusizeMessageHandler (Optional)](#4-implement-virtusizemessagehandler-optional)
  - [Allow Cookie Sharing (Optional)](#5-allow-cookie-sharing-optional)
  - [Listen to Product Data Check (Optional)](#6-listen-to-product-data-check-optional)
- [Virtusize Views](#virtusize-views)
  - [Virtusize Button](#1-virtusize-button)
  - [Virtusize InPage](#2-virtusize-inpage)
    - [InPage Standard](#2-inpage-standard)
    - [InPage Mini](#3-inpage-mini)
- [SwiftUI](#swiftui)
- [The Order API](#the-order-api)
  - [Initialization](#1-initialization)
  - [Create a _VirtusizeOrder_ structure for order data](#2-create-a-virtusizeorder-structure-for-order-data)
  - [Send an Order](#3-send-an-order)
- [Enable SNS Login in Virtusize for native Webview apps](#enable-sns-login-in-virtusize-for-native-webview-apps)
- [Build](#build)
- [Run all tests](#run-all-tests)
- [Roadmap](#roadmap)
- [License](#license)

## Requirements

- iOS 13.0+
- Xcode 12+
- Swift 5.0+

## Installation

If you'd like to continue using the older Version 1.x.x, refer to the branch [v1](https://github.com/virtusize/integration_ios/tree/v1).

### CocoaPods

Install using the [CocoaPods](https://cocoapods.org) dependency manager. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Virtusize SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target '<your-target-name>' do
pod 'Virtusize', '~> 2.12.2'
end
```

Then, run the following command:

```bash
$ pod repo update
$ pod install
```

### Swift Package Manager

Starting with the `2.3.2` release, Virtusize supports installation via [Swift Package Manager](https://swift.org/package-manager/)

1. In Xcode, select **File** > **Swift Packages** > **Add Package Dependency...** and enter `https://github.com/virtusize/integration_ios.git` as the repository URL.
2. Select a minimum version of `2.12.2`
3. Click **Next**

### Carthage

Install using the [Carthage](https://github.com/Carthage/Carthage) dependency manager. You can install it with the following command:

```bash
brew install carthage
```

To integrate Virtusize SDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```bash
github "virtusize/integration_ios"
```

Then, run the following command:

```bash
$ carthage update
```

Follow `Carthage` [documentation](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for further instruction on how to link the framework and build it.

## Setup

### 1. Initialization

Set up the SDK in the App delegate's `application(_:didFinishLaunchingWithOptions:)` method.

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Virtusize.APIKey is required
    Virtusize.APIKey = "15cc36e1d7dad62b8e11722ce1a245cb6c5e6692"
    // For using the Order API, Virtusize.userID is required
    Virtusize.userID = "123"
    // By default, the Virtusize environment will be set to .GLOBAL
    Virtusize.environment = .STAGING
    Virtusize.params = VirtusizeParamsBuilder()
        // By default, the initial language will be set based on the Virtusize environment
        .setLanguage(.JAPANESE)
        // By default, ShowSGI is false
        .setShowSGI(true)
        // By default, Virtusize allows all the possible languages including English, Japanese and Korean
        .setAllowedLanguages([VirtusizeLanguage.ENGLISH, VirtusizeLanguage.JAPANESE])
        // By default, Virtusize displays all the possible info categories in the Product Details tab,
        // including "modelInfo", "generalFit", "brandSizing" and "material".
        .setDetailsPanelCards([VirtusizeInfoCategory.BRANDSIZING, VirtusizeInfoCategory.GENERALFIT])
        // By default, Virtusize enables the SNS buttons
        .setShowSNSButtons(true)
        // Target the specific environment branch by its name
        .setBranch("branch-name")
        .build()

    return true
}
```

The environment is the region you are running the integration from, either `.STAGING`, `.GLOBAL`, `.JAPAN` or `.korea`

You can set up the `Virtusize.params` by using **VirtusizeParamsBuilder** to change the configuration of the integration. Possible configuration methods are shown in the following table:

**VirtusizeParamsBuilder**

| Method | Argument Type | Example | Description | Requirement |
| ---------- | ---------------------- | ------------ | ---------------- | ----------------- |
| setLanguage | VirtusizeLanguage | setLanguage(.JAPANESE) | Sets the initial language that the integration will load in. The possible values are `VirtusizeLanguage.ENGLISH`, `VirtusizeLanguage.JAPANESE` and `VirtusizeLanguage.KOREAN` | No. By default, the initial language will be set based on the Virtusize environment. |
| setShowSGI | Boolean | setShowSGI(true) | Determines whether the integration will fetch SGI and use SGI flow for users to add user generated items to their wardrobe. | No. By default, ShowSGI is set to false |
| setAllowedLanguages  | A list of `VirtusizeLanguage` | setAllowedLanguages([VirtusizeLanguage.ENGLISH, VirtusizeLanguage.JAPANESE]) | The languages that the user can switch to using the Language Selector | No. By default, the integration allows all the possible languages to be displayed, including English, Japanese and Korean. |
| setDetailsPanelCards | A list of `VirtusizeInfoCategory` | setDetailsPanelCards([VirtusizeInfoCategory.BRANDSIZING, VirtusizeInfoCategory.GENERALFIT]) | The info categories which will be displayed in the Product Details tab. Possible categories are: `VirtusizeInfoCategory.MODELINFO`, `VirtusizeInfoCategory.GENERALFIT`, `VirtusizeInfoCategory.BRANDSIZING` and `VirtusizeInfoCategory.MATERIAL` | No. By default, the integration displays all the possible info categories in the Product Details tab. |
| setShowSNSButtons | Boolean | setShowSNSButtons(true)| Determines whether the integration will show SNS buttons | No. By default, ShowSNSButtons is set to true |
| setBranch | String | setBranch("branch-name")| Targets specific environment branch | No. By default, production environment is targeted. `staging` - staging environment is targeted. `<branch-name>` a specific branch is targeted |


#### (Optional) Confgiure Internal Logger

You can enable internal logger for debugging purpose by updating App delegate:

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Setup Virtusize LogLevel
		VirtusizeLogger.logLevel = .debug // `.none` is default
		// Override Virtusize log handler, if necessary
		//VirtusizeLogger.logHandler = { logLevel, message in
		//	print("[Virtusize] \(logLevel): \(message)")
		//}

    // ... continue Virtusize and App initialization

    return true
}
```

### 2. Load Product with Virtusize SDK

In the view controller for your product page, you will need to use `Virtusize.load` to populate the Virtusize views:

- Create a `VirtusizeProduct` object with:
  - An `exernalId` that will be used to reference the product in the Virtusize server
  - An `imageURL` for the product image
- Pass the `VirtusizeProduct` object to the `Virtusize.load` method

```Swift
override func viewDidLoad() {
    super.viewDidLoad()

    // Declare a `VirtusizeProduct` variable, which will be passed to the `Virtusize` views in order to bind the product info
    let product = VirtusizeProduct(
        // Set the product's external ID
        externalId: "vs_dress",
        // Set the product image URL
        imageURL: URL(string: "http://www.example.com/image.jpg")
    )

    // Load the product in order to populate the `Virtusize` views
    Virtusize.load(product: product)
}
```

### 3. Enable SNS authentication

The SNS authentication flow requires switching to a SFSafariViewController, which will load a web page for the user to login with their SNS account. A custom URL scheme must be defined to return the login response to your app from a SFSafariViewController.

#### Step 1: Register a URL type

In Xcode, click on your project's **Info** tab and select **URL Types**.

Add a new URL type and set the URL Schemes and identifier to `com.your-company.your-app.virtusize`

![Screen Shot 2021-11-10 at 21 36 31](https://user-images.githubusercontent.com/7802052/141114271-373fb239-91f8-4176-830b-5bc505e45017.png)

#### Step 2: Set up application callback handler

Implement App delegate's `application(_:open:options)` method (for older projects):

```Swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return Virtusize.handleUrl(url)
}
```

Implement Scene delegate's `scene(_:openURLContexts)` method (for newer projects):

```Swift
func scene(_ scene: UIScene, openURLContexts: Set<UIOpenURLContext>) {
    if let urlContext = openURLContexts.first {
        _ = Virtusize.handleUrl(urlContext.url)
    }
}
```

If both files (`AppDelegate` and `SceneDelegate`) are present, use `SceneDelegate` to handle SNS callbacks.


#### ❗IMPORTANT

1. The URL type must include your app's bundle ID and **end with .virtusize**.
2. If you have multiple app targets, add the URL type for all of them.


#### (Optional) Configure custom branch

You can test custom environment branch by updating the URL loaded by a WebView:

```Swift
    let url = VirtusizeBranch.applyBranch(
        to: URL(string: "https://demo.virtusize.com")!,
 	    branch: "branch-name")
    webView.load(URLRequest(url: url))
```

### Enable SNS Login in Virtusize for Native Webview Apps

Use either of the following methods to enable Virtusize SNS login in WebView

#### Method 1: Use the VirtusizeWebView

#### Replace `WKWebview` that loads Virtusize with `VirtusizeWebView`

To enable Virtusize SNS login on the web version of Virtusize integration inside your web view, please use this method:

1. If you have built your UI purely with UIKit, replace your `WKWebView` with **`VirtusizeWebView`** in your Swift file. If you use the `WKWebViewConfiguration` object to configure your web view, please access it from the closure like the example below.

   - Swift

   ```diff
   - var webView: WKWebView
   + var webView: VirtusizeWebView
   ```

   ```swift
   webView = VirtusizeWebView(frame: .zero) { configuration in
       // access the WKWebViewConfiguration object here to customize it
       
       // If you want to allow cookie sharing between multiple VirtusizeWebViews,
       // assign the same WKProcessPool object to configuration.processPool
       configuration.processPool = WKProcessPool()
   }
   ```

2. If you have built your UI with Xcode's Interface Builder, make sure that you set the Custom Class of your web view to **`VirtusizeWebView`** in the Identity inspector.

   - Swift

   ```diff
   - @IBOutlet weak var webview: WKWebView!
   + @IBOutlet weak var webview: VirtusizeWebView!
   ```

   - Interface Builder

     ![img](https://user-images.githubusercontent.com/7802052/121308895-87e3b500-c93c-11eb-8745-f4bf22bccdba.png)

#### Method 2: Use WKWebView

#### Step 1: Set `javaScriptCanOpenWindowsAutomatically` to true

```swift
yourWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
```

#### Step 2: Set `customUserAgent` to ensure Google SDK works within WebView

```swift
yourWebView.customUserAgent = VirtusizeAuthConstants.userAgent
```

#### Step 3: Make sure your view controller confirms the `WKNavigationDelegate` and implement the code below to enable SNS buttons in Virtusize

```swift
class YourViewController: UIViewController {
    
    private var yourWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ... the other code
        
        yourWebView.navigationDelegate = self
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.virtusizeSNSEnabled = true;")
    }
}
```

#### Step 4: Make sure your view controller confirms the `WKUIDelegate` and implement the code below

```swift
class YourViewController: UIViewController {
    
    private var yourWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ... the other code
        
        yourWebView.uiDelegate = self
    }
}

extension YourViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        if VirtusizeURLCheck.isExternalLinkFromVirtusize(url: url.absoluteString) {
            UIApplication.shared.open(url, options: [:])
            return nil
        }
        
        if VirtusizeAuthorization.isSNSAuthURL(viewController: self, webView: webView, url: url) {
            return nil
        }
        
        if navigationAction.targetFrame == nil && VirtusizeURLCheck.isLinkFromSNSAuth(url: url.absoluteString) {
            // By default, the Google sign-in page shows a 403 error: disallowed_useragent if you are visiting it within a web view.
            // By setting up the user agent, Google recognizes the web view as a Safari browser
            configuration.applicationNameForUserAgent = "CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"
            let popupWebView = WKWebView(frame: webView.frame, configuration: configuration)
            popupWebView.uiDelegate = self
            webView.addSubview(popupWebView)
            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: webView.topAnchor),
                popupWebView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
                popupWebView.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
            ])
            return popupWebView
        }
        
        // The rest of your code ...
        
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
}
```

### Migration Guide (from 2.x to 2.8.0)

#### Step 1: Setup AppDelegate or SceneDelegate to handle callback URL

```Swift
// For older apps - update AppDelegate (when SceneDelegate` is not yet used)
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return Virtusize.handleUrl(url)
}
```

```Swift
// For newer apps, update SceneDelegate
func scene(_ scene: UIScene, openURLContexts: Set<UIOpenURLContext>) {
    if let urlContext = openURLContexts.first {
        _ = Virtusize.handleUrl(urlContext.url)
    }
}
```

#### Step 2: Remove `setAppBundleId` function call

```diff
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	// Virtusize initialization omitted for brevity
-   VirtusizeAuth.setAppBundleId("com.your-company.your-app")
	return true
}
```

#### Step 3: (Optional) for native WebView apps, set `customUserAgent` to ensure Google SDK works within WebView

```swift
// if yourWebView is WKWebView
yourWebView.customUserAgent = VirtusizeAuthConstants.userAgent
```

### 4. Implement VirtusizeMessageHandler (Optional)

The `VirtusizeMessageHandler` protocol has two required methods:

- `virtusizeController(_:didReceiveError:)` is called when the controller is reporting a network or deserialisation error.
- `virtusizeController(_:didReceiveEvent:)` is called when data is exchanged between
  the controller and the Virtusize API. `VirtusizeEvent` is a `struct` with a required `name` and an optional `data` property.

```Swift
extension ViewController: VirtusizeMessageHandler {
    func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveEvent event: VirtusizeEvent) {
        print(event)
        switch event.name {
		    case "user-opened-widget":
            return
		    case "user-opened-panel-compare":
            return
		    default:
            return
        }
    }

    func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveError error: VirtusizeError) {
        print(error)
    }
}
```

### 5. Allow Cookie Sharing (Optional)

The `VirtusizeWebViewController` accepts an optional `processPool:WKProcessPool` paramater to allow cookie sharing.

```Swift
// Optional: Set up WKProcessPool to allow cookie sharing.
Virtusize.processPool = WKProcessPool()
```

### 6. Listen to Product Data Check (Optional)

When the button is initialized with an `exernalId` , the SDK calls our API to check if the product has been parsed and added to our database.

In order to debug that API call, you can subscribe to the `NotificationCenter` and observe two `Notification.Name` aliases:

- `Virtusize.productCheckDidFail`, which receives the `UserInfo` containing a message with the cause of the failure.
- `Virtusize.productCheckDidSucceed` that will be sent if the call is succesfull.

If the check fails, the button will be hidden.

You can check the example project to see one possible implementation.

## Virtusize Views

After setting up the SDK, add a `VirtusizeView` to allow your customers to find their ideal size.

Virtusize SDK provides two main UI components for clients to use:

### 1. Virtusize Button

#### (1) Introduction

VirtusizeButton is the simplest UI Button for our SDK. It opens our application in the web view to support customers finding the right size.

#### (2) Default Styles

There are two default styles of the Virtusize Button in our Virtusize SDK.

|                                                    Teal Theme                                                     |                                                    Black Theme                                                    |
| :---------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/7802052/92671785-22817a00-f352-11ea-8ce9-6b4f7fcb43c4.png" /> | <img src="https://user-images.githubusercontent.com/7802052/92671771-172e4e80-f352-11ea-8443-dcb8b05f5a07.png" /> |

If you like, you can also customize the button style.

#### (3) Usage

**A. Add the Virtusize Button**

- To use the Virtusize Button on the product page of your store, you can either:

  - Create a _UIButton_ in the Xcode’s Interface Builder Storyboard, set the Custom Class to `VirtusizeButton` in the Identity inspector and ensure the button is hidden when loading.

    <img src="https://user-images.githubusercontent.com/7802052/92836674-a487a680-f417-11ea-81d0-5aa32390167a.png" style="zoom:70%;" />

  - Or add the VirtusizeButton programmatically:

    ```swift
    let virtusizeButton = VirtusizeButton()
    view.addSubview(virtusizeButton)
    ```

  - In order to use our default styles, set the property _style_ of VirtusizeButton as `VirtusizeViewStyle.TEAL` or `VirtusizeViewStyle.BLACK`

    ```swift
    virtusizeButton.style = .TEAL
    ```

  - You can also customize the button's style attributes. For example, the titlelabel's text, height, width, etc.

**B. Connect the Virtusize button, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`) **into the Virtusize API by using the `Virtusize.setVirtusizeView` method.**

```swift
Virtusize.setVirtusizeView(self, virtusizeButton, product: product)
```

### 2. Virtusize InPage

#### (1) Introduction

Virtusize InPage is a button that behaves like a start button for our service. The button also behaves as a fitting guide that supports customers to find the right size.

##### InPage types

There are two types of InPage in the Virtusize SDK.

|                                                    InPage Standard                                                     |                                                    InPage Mini                                                     |
| :--------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![InPageStandard](https://user-images.githubusercontent.com/7802052/92671977-9cb1fe80-f352-11ea-803b-5e3cb3469be4.png) | ![InPageMini](https://user-images.githubusercontent.com/7802052/92671979-9e7bc200-f352-11ea-8594-ed441649855c.png) |

⚠️**Caution**⚠️

1. InPage cannot be implemented together with the Virtusize button. Please pick either InPage or Virtusize button for your online shop.

2. InPage Mini must always be used in combination with InPage Standard.

#### (2) InPage Standard

##### A. Usage

- **Add a VirtusizeInPageStandard**

  - To use the Virtusize InPage Standard on the product page of your store, you can either:

    - Create a _UIView_ in the Xcode’s Interface Builder, then set the Custom Class to `VirtusizeInPageStandard` in the Identity inspector and ensure the view is hidden when loading.

      <img src="https://user-images.githubusercontent.com/7802052/92836755-ba956700-f417-11ea-8fb4-e9d9e2291031.png" style="zoom:70%;" />

      Be sure to set up constraints for InPage Standard and then go to the Size inspector -> find _Intrinsic Size_ -> Select _Placeholder_ in order to have the dynamic height dependent on its content.

      <img src="https://user-images.githubusercontent.com/7802052/92836828-ce40cd80-f417-11ea-94a7-999cb3e063a4.png" style="zoom:70%;" />

    - Or add the Virtusize InPage Standard programmatically:

      ```swift
      let inPageStandard = VirtusizeInPageStandard()
      view.addSubview(inPageStandard)
      ```

  - In order to use our default styles, set the property _style_ of VirtusizeInPageStandard as `VirtusizeViewStyle.TEAL` or `VirtusizeViewStyle.BLACK`

  - If you'd like to change the background color of the CTA button, you can use the property `inPageStandardButtonBackgroundColor` to set the color

    ```swift
    // Set the InPage Standard style to VirtusizeStyle.BLACK
    inPageStandard.style = .BLACK
    // Set the background color of the CTA button to UIColor.blue
    inPageStandard.inPageStandardButtonBackgroundColor = UIColor.blue
    ```

    ```swift
    // Set the InPage Standard style to VirtusizeStyle.TEAL
    inPageStandard.style = .TEAL
    // Set the background color of the CTA button to a custom color using ColorLiteral
    inPageStandard.inPageStandardButtonBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    ```

  - When you add the VirtusizeInPageStandard programmatically and you'd like to set the horizontal margins between the edges of the app screen and the VirtusizeInPageStandard, you can use `setHorizontalMargin`

    If you'd like to set a direct width for InPage Standard, use auto layout constraints.

    ```swift
    // Set the horizontal margins to 16
    inPageStandard.setHorizontalMargin(view: view, margin: 16)

    // Or set the direct width for InPage Standard programtically
    inPageStandard.translatesAutoresizingMaskIntoConstraints = false
    inPageStandard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inPageStandard.widthAnchor.constraint(equalToConstant: 350).isActive = true
    ```

  - If you'd like to change the font sizes of InPage Standard, you can use the properties `messageFontSize` and `buttonFontSize`.

    ```swift
    inPageStandard.buttonFontSize = 12
    inPageStandard.messageFontSize = 12
    ```

- **Connect the Virtusize InPage Standard, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`) **into the Virtusize API by using the `Virtusize.setVirtusizeView` method.**

  ```swift
  Virtusize.setVirtusizeView(self, inPageStandard, product: product)
  ```

##### B. Design Guidelines

- ##### Default Designs

  There are two default design variations.

  |                                                         Teal Theme                                                         |                                                         Black Theme                                                         |
  | :------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------: |
  | ![InPageStandardTeal](https://user-images.githubusercontent.com/7802052/92672035-b9e6cd00-f352-11ea-9e9e-5385a19e96da.png) | ![InPageStandardBlack](https://user-images.githubusercontent.com/7802052/92672031-b81d0980-f352-11ea-8b7a-564dd6c2a7f1.png) |

- ##### Layout Variations

  Here are some possible layouts

  |                                                     1 thumbnail + 2 lines of message                                                     |                                                         2 thumbnails + 2 lines of message                                                          |
  | :--------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------: |
  | ![1 thumbnail + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399368-5e879300-1930-11eb-8b77-b49e06813550.png) |     ![2 thumbnails + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399370-5f202980-1930-11eb-9a2d-7b71714aa7b4.png)      |
  |                                                   **1 thumbnail + 1 line of message**                                                    |                                                   **2 animated thumbnails + 2 lines of message**                                                   |
  | ![1 thumbnail + 1 line of message](https://user-images.githubusercontent.com/7802052/97399373-5f202980-1930-11eb-81fe-9946b656eb4c.png)  | ![2 animated thumbnails + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399355-59c2df00-1930-11eb-8a52-292956b8762d.gif) |

- ##### Recommended Placement

  - Near the size table

  - In the size info section

    <img src="https://user-images.githubusercontent.com/7802052/92672185-15b15600-f353-11ea-921d-397f207cf616.png" style="zoom:50%;" />

- ##### UI customization

  - **You can:**

    - change the background color of the CTA button as long as it passes **[WebAIM contrast test](https://webaim.org/resources/contrastchecker/)**.
    - change the width of InPage so it fits your application width.

  - **You cannot:**
    - change interface components such as shapes and spacing.
    - change the font.
    - change the CTA button shape.
    - change messages.
    - change or hide the box shadow.
    - hide the footer that contains VIRTUSIZE logo and Privacy Policy text link.

#### (3) InPage Mini

This is a mini version of InPage which can be placed in your application. The discreet design is suitable for layouts where customers are browsing product images and size tables.

##### A. Usage

- **Add a VirtusizeInPageMini**

  - To use the Virtusize InPage Mini on the product page of your store, you can either:

    - Create a _UIView_ in the Xcode’s Interface Builder, set the Custom Class to `VirtusizeInPageMini` in the Identity inspector and ensure the view is hidden when loading.

      <img src="https://user-images.githubusercontent.com/7802052/92836772-bf5a1b00-f417-11ea-9ef3-03a9079a7834.png" style="zoom:70%;" />

      Be sure to set up constraints for InPage Mini and then go to the Size inspector -> find _Intrinsic Size_ -> Select _Placeholder_ in order to have the dynamic height dependent on its content.

      <img src="https://lh3.googleusercontent.com/wARRXwn4a7tHe4wSzqkqCmlAeVRzQSObBpHPU0G0UAYGjLen0laqc325pmoaxadXFcuzvCnDT9R3jhtq42SKF21KgcRkOQU7OkCdMXm9wGdmzPCDyyk9y9CuOmVJTG8co0_-E4QR" style="zoom:70%;" />

    - Or add the Virtusize InPage Mini programmatically:

      ```swift
      let inPageMini = VirtusizeInPageMini()
      view.addSubview(inPageMini)
      ```

  - In order to use our default styles, set the property _style_ of VirtusizeInPageMini as `VirtusizeViewStyle.TEAL` or `VirtusizeViewStyle.BLACK`

  - If you'd like to change the background color of the bar, you can use the property `inPageMiniBackgroundColor` to set the color.

    ```swift
    inPageMini.style = .TEAL
    inPageMini.inPageMiniBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    ```

  - When you add the VirtusizeInPageMini programtically and you'd like to set up the horizontal margins between the edges of the app screen and the VirtusizeInPageMini, you can use `setHorizontalMargin`

    If you'd like to set a direct width for InPage Mini, use auto layout constraints.

    ```swift
    // Set the horizontal margins to 16
    inPageMini.setHorizontalMargin(view: view, margin: 16)

    // Or set the direct width for InPage Standard programtically
    inPageMini.translatesAutoresizingMaskIntoConstraints = false
    inPageMini.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inPageMini.widthAnchor.constraint(equalToConstant: 350).isActive = true
    ```

  - If you'd like to change the font sizes of InPage Mini, you can use the properties `messageFontSize` and `buttonFontSize`.

    ```swift
    inPageMini.messageFontSize = 12
    inPageMini.buttonFontSize = 10
    ```

- **Connect the Virtusize InPage Mini, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`) **into the Virtusize API by using the `Virtusize.setVirtusizeView` method.**

  ```swift
  Virtusize.setVirtusizeView(self, inPageMini, product: product)
  ```

##### B. Design Guidelines

- ##### Default designs

  There are two default design variations.

  |                                                       Teal Theme                                                       |                                                       Black Theme                                                       |
  | :--------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------: |
  | ![InPageMiniTeal](https://user-images.githubusercontent.com/7802052/92672234-2d88da00-f353-11ea-99d9-b9e9b6aa5620.png) | ![InPageMiniBlack](https://user-images.githubusercontent.com/7802052/92672232-2c57ad00-f353-11ea-80f6-55a9c72fb0b5.png) |

- ##### Recommended Placements

  |                                           Underneath the product image                                            |                                         Underneath or near the size table                                         |
  | :---------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------: |
  | <img src="https://user-images.githubusercontent.com/7802052/92672261-3c6f8c80-f353-11ea-995c-ede56e0aacc3.png" /> | <img src="https://user-images.githubusercontent.com/7802052/92672266-40031380-f353-11ea-8f63-a67c9cf46c68.png" /> |

- ##### Default Fonts

  - **Japanese**
    - Noto Sans JP
    - 12pt (Message)
    - 10pt (Button)
  - **Korean**
    - Noto Sans KR
    - 12pt (Message)
    - 10pt (Button)
  - **English**
    - San Francisco (System Default)
    - 14pt (Message)
    - 12pt (Button)

- ##### UI customization

  - **You can:**
    - change the background color of the bar as long as it passes **[WebAIM contrast test](https://webaim.org/resources/contrastchecker/)**.
  - **You cannot:**
    - change the font.
    - change the CTA button shape.
    - change messages.


## SwiftUI

### 1. Set up the SDK in the App delegate's  `application(_:didFinishLaunchingWithOptions:)` method.

Check the [Set Up](#1-initialization) section for the example code

```Swift
@main
struct ExampleApp: App {
  init() {
    // Initialize Virtusize
    Virtusize.APIKey = "api-key"
    Virtusize.params = VirtusizeParamsBuilder()
      // ... conifgure Virtusize parameters
      .build()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL(perform: { url in
          // Handle Virtusize SNS callback
          _ = Virtusize.handleUrl(url)
        })
    }
  }
}
```

### 2. Set up the product details in your product SwiftUI view

```Swift
struct ProductView: View {
	init() {
		// Set up the product information in order to populate the Virtusize view
		Virtusize.product = VirtusizeProduct(
			externalId: "vs_dress",
			imageURL: URL(string: "http://www.example.com/image.jpg")
		)
	}
	
	...
}
```

### 3. There are three Virtusize SwiftUI components that you can use:

- **SwiftUIVirtusizeButton:** is equivalent to [Virtusize Button](#1-virtusize-button)

```Swift
struct ProductView: View {
	var body: some View {
		VStack {
			SwiftUIVirtusizeButton(
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional) You can customize the button by accessing it here
				uiView: { virtusizeButton in
						virtusizeButton.setTitle("Check size", for: .normal)
						virtusizeButton.backgroundColor = .vsBlackColor
				},
				// (Optional) You can use our default styles: either Black or Teal for the button.
				// If you want to customize the button on your own, please omit defaultStyle
				defaultStyle: .BLACK
			)
		}
	}
}	
```

- **SwiftUIVirtusizeInPageStandard**: is equivalent to [InPage Standard](#2-inpage-standard)

```Swift
struct ProductView: View {
	var body: some View {
		VStack {
			SwiftUIVirtusizeInPageStandard(
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional): You can customize the button by accessing it here
				uiView: { virtusizeInPageStandard in
					virtusizeInPageStandard.buttonFontSize = 12
					virtusizeInPageStandard.messageFontSize = 12
					virtusizeInPageStandard.inPageStandardButtonBackgroundColor = .vsBlackColor
					virtusizeInPageStandard.setHorizontalMargin(margin: 16)
				},
				// (Optional): You can use our default styles either Black or Teal for the InPage Standard view.
				// The default is set to .BLACK.
				defaultStyle: .BLACK
			)
		}
	}
}
```

- **SwiftUIVirtusizeInPageMini**: is equivalent to [InPage Mini](#3-inpage-mini)

```Swift
struct ProductView: View {
	var body: some View {
		VStack {
			SwiftUIVirtusizeInPageMini(
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional): You can customize the button by accessing it here
				uiView: { virtusizeInPageMini in
					virtusizeInPageMini.messageFontSize = 12
					virtusizeInPageMini.buttonFontSize = 10
					virtusizeInPageMini.inPageMiniBackgroundColor = .vsTealColor
					virtusizeInPageMini.setHorizontalMargin(margin: 16)
				},
				// (Optional): You can use our default styles either Black or Teal for the InPage Mini view.
				// The default is set to .BLACK.
				defaultStyle: .TEAL
			)
		}
	}
}
```

### 4. Use **SwiftUIVirtusizeViewController** to open the Virtusize web view when any of the above components are clicked. 

```Swift
struct ProductView: View {
	// Declare a Boolean state to control when to open the Virtusize web view
	@State var showVirtusizeWebView = false

	var body: some View {
		VStack {
			SwiftUIVirtusizeButton(
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				...
			)
		}
		// MARK: SwiftUIVirtusizeViewController
		.sheet(isPresented: $showVirtusizeWebView) {
			SwiftUIVirtusizeViewController(
				// (Optional): Set up WKProcessPool to allow cookie sharing
				processPool: WKProcessPool(),
				// (Optional): You can use this callback closure to receive Virtusize events
				didReceiveEvent: { event in
					print(event)
					switch event.name {
					case "user-opened-widget":
						return
					case "user-opened-panel-compare":
						return
					default:
						return
					}
				},
				// (Optional): You can use this callback closure to receive Virtusize SDK errors
				didReceiveError: { error in
					print(error)
				}
			)
		}
	}
}
```

### 5. Listen to Product Data Check (Optional) 

You can set up NotificationCenter listeners with the *onReceive* modifier to debug the product data check

```Swift
struct ProductView: View {
	var body: some View {
		VStack {
			SwiftUIVirtusizeButton(
				...
			)
		}
		.sheet(isPresented: $showVirtusizeWebView) {
			SwiftUIVirtusizeViewController(
				...
			)
		}
    // (Optional): You can set up NotificationCenter listeners to debug the product data check
		// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message with the cause of the failure
		// - `Virtusize.productDataCheckDidSucceed`
		.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidSucceed)) { notification in
			print(notification)
		}
		.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidFail)) { notification in
			print(notification)
		}
  }
}
```


### 6. For integrating the other optional features listed below, you can check out the [ExampleSwiftUI](/ExampleSwiftUI) for a detailed implementation.

- Allow cookie sharing
- Hide the space of the Virtusize SwiftUI components
- Make the Virtusize web view full screen


## The Order API

The order API enables Virtusize to show your customers the items they have recently purchased as part of their `Purchase History`, and use those items to compare with new items they want to buy.

#### 1. Initialization

Make sure to set up the **user ID** before sending orders to Virtusize. You can set up the user ID either:

in the `application(_:didFinishLaunchingWithOptions:)` method of the App delegate before the app is launched

or

in your view controller after the app is launched

```Swift
Virtusize.userID = "123"
```

#### 2. Create a _VirtusizeOrder_ structure for order data

The **_VirtusizeOrder_** structure gets passed to the `Virtusize.sendOrder` method, and has the following properties:

****Note:**** \* means the property is required

**VirtusizeOrder**
| Property | Data Type | Example | Description |
| ---------------- | -------------------------------------- | ------------------- | ----------------------------------- |
| externalOrderId* | String | "20200601586" | The order ID provided by the client |
| items* | An array of `VirtusizeOrderItem` structures | See the table below | An array of the order items. |

**VirtusizeOrderItem**
| Property | Data Type | Example | Description |
| ---------- | --------- | ---------------------------------------- | ------------------------------------------------------------ |
| externalProductId* | String | "A001" | The external product ID provided by the client. It must be unique for a product. |
| size* | String | "S", "M", etc. | The name of the size |
| sizeAlias | String | "Small", "Large", etc. | The alias of the size is added if the size name is not identical from the product page |
| variantId | String | "A001_SIZES_RED" | An ID that is set on the product SKU, color, or size if there are several options for the item |
| imageUrl* | String | "http[]()://images.example.com/coat.jpg" | The image URL of the item |
| color | String | "RED", "R', etc. | The color of the item |
| gender | String | "W", "Women", etc. | An identifier for the gender |
| unitPrice* | Float | 5100.00 | The product price that is a float number with a maximum of 12 digits and 2 decimals (12, 2) |
| currency* | String | "JPY", "KRW", "USD", etc. | Currency code |
| quantity* | Int | 1 | The number of the item purchased. If it's not passed, It will be set to 1 |
| url | String | "http[]()://example.com/products/A001" | The URL of the product page. Please make sure this is a URL that users can access |

**Sample**

```Swift
var virtusizeOrder = VirtusizeOrder(externalOrderId: "2020060812345")
let item = VirtusizeOrderItem(
    externalProductId: "A00001",
    size: "L",
    sizeAlias: "Large",
    variantId: "A00001_SIZEL_RED",
    imageUrl: "http://images.example.com/products/A00001/red/image1xl.jpg",
    color: "Red",
    gender: "W",
    unitPrice: 5100.00,
    currency: "JPY",
    quantity: 1,
    url: "http://example.com/products/A00001"
)
virtusizeOrder.items = [item]
```

#### 3. Send an Order

Call the `Virtusize.sendOrder` method in your activity or fragment when the user places an order.
The `onSuccess` and `onError` callbacks are optional.

```Swift
Virtusize.sendOrder(
    virtusizeOrder,
    // This success callback is optional and gets called when the app successfully sends the order
    onSuccess: {
        print("Successfully sent the order")
},
    // This error callback is optional and gets called when an error occurs
    // when the app is sending the order
    onError: { error in
        print("Failed to send the order, error: \(error.debugDescription)")
})
```

## Enable SNS Login in Virtusize for Native Webview Apps

See [VirtusizeAuth for WebView Apps Setup](/VirtusizeAuth/README.md)

## Contributing

### Build

You need to install [SwiftLint](https://github.com/realm/SwiftLint).

    make build

### Run all tests

    make test

### Linter

We use [swiftlint](https://github.com/realm/SwiftLint) for formatting. It's integrated into the XCode build steps.
But you can also call it from command line.

```sh
# install swiftlint
brew install swiftlint

# run linter
swiftlint

# auto-correct warnings
swiftlint --fix

# or run linter from Makefile
make lint
make lint-fix
```

### Git Hooks

Ensure to setup the `pre-push` git hooks after cloning the repo.  
Git hook will run linter and tests on every push automatically.
```sh
make install-git-hooks
```

### Fonts & Localisation

We use subset fonts to reduce the overall SDK size.  
The subset glyphs are limited to the characters used in the localization files.

Whenever you update the localization files, ensure to regenerate the subset fonts of the SDK.
```sh
# Ensure to install FontTools
pip install --upgrade fonttools

sh ./Scripts/build_fonts.sh
```

## Roadmap

Please check the [Roadmap](ROADMAP.md) to find upcoming features and expected release dates.

## License

Copyright (c) 2018-21 Virtusize CO LTD (https://www.virtusize.jp)
