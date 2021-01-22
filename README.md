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

## Requirements

- iOS 10.3+
- Xcode 10.1+
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
platform :ios, '10.3'
use_frameworks!

target '<your-target-name>' do
pod 'Virtusize', '~> 2.0.5'
end
```

Then, run the following command:

```bash
$ pod install
```
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

First setup the SDK in the `application(_:didFinishLaunchingWithOptions:)` 
method of the App delegate.

``` Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Virtusize.APIKey is required
    Virtusize.APIKey = "15cc36e1d7dad62b8e11722ce1a245cb6c5e6692"
    // For using the Order API, Virtusize.userID is required
    Virtusize.userID = "123"
    // By default, the Virtusize environment will be set to .global
    Virtusize.environment = .staging
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
        .build()
        return true
}
```

The environment is the region you are running the integration from, either `.staging`,  `.global`,
`.japan` or `.korea`

You can set up the `Virtusize.params` by using **VirtusizeParamsBuilder** to change the configuration of the integration. Possible configuration methods are shown in the following table: 

**VirtusizeParamsBuilder**

| Method               | Argument Type                     | Example                                                      | Description                                                  | Requirement                                                  |
| -------------------- | --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| setLanguage          | VirtusizeLanguage                 | setLanguage(.JAPANESE)                                       | Sets the initial language that the integration will load in. The possible values are `VirtusizeLanguage.ENGLISH`, `VirtusizeLanguage.JAPANESE` and `VirtusizeLanguage.KOREAN` | No. By default, the initial language will be set based on the Virtusize environment. |
| setShowSGI           | Boolean                           | setShowSGI(true)                                             | Determines whether the integration will fetch SGI and use SGI flow for users to add user generated items to their wardrobe. | No. By default, ShowSGI is set to false                      |
| setAllowedLanguages  | A list of `VirtusizeLanguage`     | setAllowedLanguages([VirtusizeLanguage.ENGLISH, VirtusizeLanguage.JAPANESE]) | The languages that the user can switch to using the Language Selector | No. By default, the integration allows all the possible languages to be displayed, including English, Japanese and Korean. |
| setDetailsPanelCards | A list of `VirtusizeInfoCategory` | setDetailsPanelCards([VirtusizeInfoCategory.BRANDSIZING, VirtusizeInfoCategory.GENERALFIT]) | The info categories which will be displayed in the Product Details tab. Possible categories are: `VirtusizeInfoCategory.MODELINFO`, `VirtusizeInfoCategory.GENERALFIT`, `VirtusizeInfoCategory.BRANDSIZING` and `VirtusizeInfoCategory.MATERIAL` | No. By default, the integration displays all the possible info categories in the Product Details tab. |

Then in the controller where you want to use the comparison view, you will need to:

1. setup the `VirtusizeButton`
2. pass a `productImageURL` in order to populate the comparison view
3. pass an `exernalId` that will be used to reference that product in our API
4. show the Virtusize view controller when the button is pressed
5. set the `VirtusizeEventsDelegate` delegate of the view controller,
   in order to handle events and error reporting.

``` Swift
@IBOutlet weak var virtusizeButton: VirtusizeButton!

override func viewDidLoad() {
    super.viewDidLoad()

    checkTheFitButton.storeProduct = VirtusizeProduct(
        externalId: "vs_dress",
        imageURL: URL(string: "http://www.example.com/image.jpg"))

    // You can apply our default button styles
    // either .BLACK
    checkTheFitButton.applyDefaultStyle(.BLACK)
    // or .TEAL
    checkTheFitButton.applyDefaultStyle(.TEAL)
}

@IBAction func checkTheFit() {
    if let virtusize = VirtusizeViewController(
        handler: self) {
        present(virtusize, animated: true, completion: nil)
    }
}
```

The `VirtusizeViewController` accepts an optional `processPool:WKProcessPool` paramater to allow cookie sharing.

```Swift
if let virtusize = VirtusizeViewController(
    handler: self,
    processPool: processPool) {
    ...
}
```

The `VirtusizeMessageHandler`  protocol has three required methods:

- `virtusizeController(_:didReceiveError:)` is called when the controller is reporting a network or deserialisation error.
- `virtusizeController(_:didReceiveEvent:)` is called when data is exchanged between
the controller and the Virtusize API. `VirtusizeEvent` is a `struct` with a required `name` and an optional `data` property.
- `virtusizeControllerShouldClose(_) `is called when the controller is requesting to be dismissed.

## Product Data Check

When the button is initialized with an  `exernalId`  the product call our API to check if the product has been parsed and added to our database.

In order to debug that API call, you can subscribe to the `NotificationCenter` and observe two `Notification.Name`:

- `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message with the cause of the failure.
- `Virtusize.productDataCheckDidSucceed` that will be sent if the call is succesfull.

If the check fails, the button will be hidden.

You can check the example project to see a possible implementation.

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

#### 2. Create a *VirtusizeOrder* structure for order data

The ***VirtusizeOrder*** structure gets passed to the `Virtusize.sendOrder` method, and has the following properties:

__**Note:**__ * means the property is required

**VirtusizeOrder**
| Property        | Data Type                              | Example             | Description                         |
| ---------------- | -------------------------------------- | ------------------- | ----------------------------------- |
| externalOrderId* | String                                 | "20200601586"       | The order ID provided by the client |
| items*           | An array of `VirtusizeOrderItem` structures | See the table below | An array of the order items.          |

**VirtusizeOrderItem**
| Property  | Data Type | Example                                  | Description                                                  |
| ---------- | --------- | ---------------------------------------- | ------------------------------------------------------------ |
| externalProductId* | String    | "A001"                                   | The external product ID provided by the client. It must be unique for a product. |
| size*      | String    | "S", "M", etc.                           | The name of the size                                         |
| sizeAlias  | String    | "Small", "Large", etc.                   | The alias of the size is added if the size name is not identical from the product page |
| variantId  | String    | "A001_SIZES_RED"                         | An ID that is set on the product SKU, color, or size if there are several options for the item |
| imageUrl*  | String    | "http[]()://images.example.com/coat.jpg" | The image URL of the item                                    |
| color      | String    | "RED", "R', etc.                         | The color of the item                                        |
| gender     | String    | "W", "Women", etc.                       | An identifier for the gender                                 |
| unitPrice* | Float    | 5100.00                                  | The product price that is a float number with a maximum of 12 digits and 2 decimals (12, 2) |
| currency*  | String    | "JPY", "KRW", "USD", etc.                | Currency code                                                |
| quantity*  | Int       | 1                                        | The number of the item purchased. If it's not passed, It will be set to 1 |
| url        | String    | "http[]()://example.com/products/A001"   | The URL of the product page. Please make sure this is a URL that users can access |

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

## Build

You need to install [SwiftLint](https://github.com/realm/SwiftLint).

    make build

## Run all tests

    make test

## Roadmap

Please check the [Roadmap](ROADMAP.md) to find upcoming features and expected release dates.

## License

Copyright (c) 2018-21 Virtusize CO LTD (https://www.virtusize.jp)
