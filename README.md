# Virtusize iOS Integration

[![CircleCI](https://img.shields.io/circleci/project/github/virtusize/integration_ios.svg)](https://circleci.com/gh/virtusize/integration_ios)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Virtusize.svg)](https://cocoapods.org/pods/Virtusize)
[![Platform](https://img.shields.io/cocoapods/p/Virtusize.svg?style=flat)](https://developers.virtusize.com/native-ios/index.html)
[![Docs](https://img.shields.io/badge/docs--brightgreen.svg)](https://developers.virtusize.com/native-ios/index.html)
[![Twitter](https://img.shields.io/badge/twitter-@virtusize-blue.svg?style=flat)](http://twitter.com/virtusize)

Virtusize helps retailers to illustrate the size and fit of clothing, shoes and bags online, by letting customers compare the
measurements of an item they want to buy (on a retailer's product page) with an item that they already own (a reference item).
This is done by comparing the silhouettes of the retailer's product with the silhouette of the customer's reference Item.
Virtusize is a widget which opens when clicking on the Virtusize button, which is located next to the size selection on the product page.

Read more about Virtusize at https://www.virtusize.com

You need a unique API key and an Admin account, only available to Virtusize customers. [Contact our sales team](mailto:sales@virtusize.com) to become a customer.

> This is the integration script for native iOS devices only. For web integration, refer to the developer documentation on https://developers.virtusize.com

## Requirements

- iOS 10.0+
- Xcode 10.1+
- Swift 4.2+

## Installation

Install using [CocoaPods](https://cocoapods.org) dependency manager. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Virtusize SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<your-target-name>' do
    pod 'Virtusize', '~> 0.2'
end
```

Then, run the following command:

```bash
$ pod install
```

## Setup

First setup your API key and environment in the `application(_:didFinishLaunchingWithOptions:)` 
method of the App delegate.

``` Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Virtusize.APIKey = "15cc36e1d7dad62b8e11722ce1a245cb6c5e6692" // Virtusize demo store key
		Virtusize.environment = "staging"
    ...
		return true
}
```

The environment is the region you are running the integration from, either `staging`,. `global`,
`japan` or `korea`

Then in the controller where you want to use the comparison view, you will need to:

1. setup the `VirtusizeButton`
2. pass a `productImageURL` in order to populate the comparison view
3. pass an `exernal_id` that will be used to reference that product in our API
4. show the Virtusize view controller when the button is pressed
5. set the `CheckTheFitViewControllerDelegate` delegate of the view controller,
   in order to handle events and error reporting.

``` Swift
	@IBOutlet weak var checkTheFitButton: VirtusizeButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		checkTheFitButton.productImageURL = URL(string: "http://www.example.com/image.jpg")
		checkTheFitButton.productId = "vs_dress"

		checkTheFitButton.applyVirtusizeDesign()
	}

	@IBAction func checkTheFit() {
		let v = CheckTheFitViewController(virtusizeButton: checkTheFitButton)
		v.delegate = self
		present(v, animated: true, completion: nil)
	}
```

The `CheckTheFitViewControllerDelegate` has three required methods:

- `checkTheFitViewController(_:didReceiveEvent:data:)` is called when data is exchanged between
  the controller and our API.
- `checkTheFitViewControllerShouldClose(_)`is called when the controller is requesting to be dismissed.
- `checkTheFitViewController(_:didReceiveError)` is called when the controller is reporting a network or deserialisation error.

## Build

You need to install [SwiftLint](https://github.com/realm/SwiftLint).

    make build

## Run all tests

    make test

## Roadmap

Please check the [Roadmap](ROADMAP.md) to find upcoming features and expected release dates.

## License

Copyright (c) 2018 Virtusize AB (https://www.virtusize.com)
