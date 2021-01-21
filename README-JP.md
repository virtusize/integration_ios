# iOS SDK 実装ガイド

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Virtusize.svg)](https://cocoapods.org/pods/Virtusize)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Virtusize.svg?style=flat)](https://developers.virtusize.com/native-ios/index.html)
[![Docs](https://img.shields.io/badge/docs--brightgreen.svg)](https://developers.virtusize.com/native-ios/index.html)
[![Twitter](https://img.shields.io/badge/twitter-@virtusize-blue.svg?style=flat)](http://twitter.com/virtusize)

[English](README.md)

Virtusize helps retailers to illustrate the size and fit of clothing, shoes and bags online, by letting customers compare the
measurements of an item they want to buy (on a retailer's product page) with an item that they already own (a reference item).
This is done by comparing the silhouettes of the retailer's product with the silhouette of the customer's reference Item.
Virtusize is a widget which opens when clicking on the Virtusize button, which is located next to the size selection on the product page.

Read more about Virtusize at https://www.virtusize.com

You need a unique API key and an Admin account, only available to Virtusize customers. [Contact our sales team](mailto:sales@virtusize.com) to become a customer.

> This is the integration script for native iOS devices only. For web integration, refer to the developer documentation on https://developers.virtusize.com



## 対応バージョン

- iOS 10.3+
- Xcode 10.1+
- Swift 5.0+



## はじめに

### CocoaPods

[CocoaPods](https://cocoapods.org/) dependency managerをインストールして使用します。下記のコマンドでインストールが可能です。

```bash
$ gem install cocoapods
```

Virtusize SDKをXcodeのCocosPodsを使ってプロジェクトに実装する際、`Podfile`にて下記コードをご利用ください。

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!

target '<your-target-name>' do
pod 'Virtusize', '~> 2.0.4'
end
```

その後、下記のコマンドを実行してください。

```bash
$ pod install
```
### Carthage

[Carthage](https://github.com/Carthage/Carthage) dependency managerをインストールして使用します。下記のコマンドでインストールが可能です。

```bash
brew install carthage
```

Virtusize SDKをXcodeのCocosPodsを使ってプロジェクトに実装する際、 `Cartfile`にて下記コードをご利用ください。

```bash
github "virtusize/integration_ios"
```

その後、下記のコマンドを実行してください。

```bash
$ carthage update
```

`Carthage` [documentation](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)に従ってこの後の作業(フレームワークへのリンク・その実装)を行ってください。



## セットアップ

#### 1. Set Up the Virtusize Properties in the AppDelegate

Virtusizeのプロパティをアプリのdelegateの`application(_:didFinishLaunchingWithOptions:)`に設定します。

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

##### (1) Virtusize.APIKey* 必須

各クライアント様ごとに割り当てられたAPIキーを設定します

##### (2) Virtusize.userID*（[Order API](#the-order-api)が使われている場合必須）

String形式にてユーザーがアプリでログインしている場合にUser IDを設定。アプリローンチ後にユーザーIDを設定することも可能です。

##### (3) Virtusize.environment

リージョンの設定が可能です。デフォルトでは.`GLOBAL`に設定されています。

##### 実装可能例：

`VirtusizeEnvironment.staging`, 

`VirtusizeEnvironment.global`, 

`VirtusizeEnvironment.japan` or 

`VirtusizeEnvironment.korea`.

##### (4) Virtusize.params

 Virtusize.paramsは**VirtusizeParamsBuilder**を使って設定可能です。こちらで実装のコンフィギュレーションを変更できます。設定例として下記をご参照ください。

- **setLanguage**

  実装する言語を設定します。デフォルトではvirtusize environmentの言語設定に従います。

  **実装可能例：**

  `VirtusizeLanguage.ENGLISH`, 

  `VirtusizeLanguage.JAPANESE` and 

  `VirtusizeLanguage.KOREAN`.

- **setShowSGI**

  実装がSGIフローを利用してユーザーにワードローブへのSGIを利用した追加機能を使わせるかどうかをブーリアン値で設定します。**SGIを使用するかどうかはご担当者にご相談ください。**デフォルトでは`false`に設定されています。

- **setAllowedLanguages**

  ユーザーが切り替え可能な言語を設定します。デフォルトでは全ての言語に切り替え可能になっています。

- **setDetailsPanelCards**

  ユーザーが切り替え可能な言語を設定します。デフォルトでは全ての言語に切り替え可能になっています。

  **設定可能な項目：** 

  `VirtusizeInfoCategory.MODELINFO`, 

  `VirtusizeInfoCategory.GENERALFIT`, 

  `VirtusizeInfoCategory.BRANDSIZING` and 

  `VirtusizeInfoCategory.MATERIAL`.



#### 2. Virtusize Buttonの追加

バーチャサイズのボタンはバーチャサイズのサービスを立ち上げるUIエレメントです。サイト上の商品詳細ページでの利用のためにはXcodeのInterface Builder Storyboardにて`VirtusizeButton`を追加し、をIdentity inspector内でCustom Classを`VirtusizeButton`に設定(下図参照)し、ロード時には非表示になっていることを確認してください。

![](https://user-images.githubusercontent.com/7802052/92836674-a487a680-f417-11ea-81d0-5aa32390167a.png)



#### 3. Virtusize Buttonの設定

弊社サービスの比較画面をどの画面で出すのかをview controller内で設定する方法は下記です。

​	(1) `VirtusizeButton`を設定する

​	(2) 比較画面内で商品画像を表示するために`productImageURL`を渡すよう設定

​	(3) 御社むけAPIキーの中で商品を特定するために`exernalId`を渡すよう設定

​	(4) ボタンが押下されたときにVirtusize view controllerを表示

​	(5) View controller内の`VirtusizeEventsDelegate`をイベントとエラーレポートのために設定する

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



#### 4. Cookie情報共有の許可

`VirtusizeViewController`はオプションとしてCookie情報を共有するための`processPool:WKProcessPool`を許可することができます。

```Swift
if let virtusize = VirtusizeViewController(
    handler: self,
    processPool: processPool) {
    ...
}
```

#### 5. VirtusizeMessageHandler

`VirtusizeMessageHandler`のプロトコルは3つの必須項目があります。

- `virtusizeController(_:didReceiveError:)`はコントローラーがネットワークエラーやデシリアライズのエラーをレポートするときに呼び出されます。
- `virtusizeController(_:didReceiveEvent:)`はデータがコントローラとVirtusize APIの間でやりとりされたときに呼び出されます。`VirtusizeEvent`は必須の`name`とオプションの`data`プロパティと共にある`struct`です。
- `virtusizeControllerShouldClose(_)`はコントローラが無視されるようリクエストを受けた際に呼び出されます。

```swift
extension ViewController: VirtusizeMessageHandler {
    func virtusizeControllerShouldClose(_ controller: VirtusizeViewController) {
        dismiss(animated: true, completion: nil)
    }

    func virtusizeController(_ controller: VirtusizeViewController, didReceiveEvent event: VirtusizeEvent) {
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

    func virtusizeController(_ controller: VirtusizeViewController, didReceiveError error: VirtusizeError) {
        dismiss(animated: true, completion: nil)
    }
}
```



#### 6. Product Data Checkに関して

ボタンが`exernalId`と共に初期化された際、弊社のproduct data check APIはその商品がクロールされていてデータベースに入っているかを確認します。

同APIが呼び出されているかデバッグするためには2つの`Notification.Name`を`NotificationCenter`上で確認（subscribe）してください。

- `Virtusize.productDataCheckDidFail`, こちらは`UserInfo`が失敗理由と共に含まれています。
- `Virtusize.productDataCheckDidSucceed`こちらは呼び出しが成功した際に送られます。

もしData checkが失敗した場合、ボタンは非表示となります。

プロジェクト例(example project)で実装例をご確認ください。



## The Order API

The order APIはバーチャサイズがユーザーが購入した商品を`Purchase History`の一部として表示するために必要で、これらの商品がユーザーが購入検討している商品と比較可能になります。 

#### 1. 初期化

Virtusizeにリクエストを送信する前に、**user ID**が設定されていることを確認してください。以下、どちらの方法でも **user ID** を設定することが可能です。

- アプリローンチ前に、アプリ内クラスの`application(_:didFinishLaunchingWithOptions:)`にて設定
- アプリローンチ後に、ビューコントローラーにて設定


```Swift
Virtusize.userID = "123"
```



#### 2.  注文データ向けに*VirtusizeOrder* オブジェクトを作成

***VirtusizeOrder***オブジェクトは`Virtusize.sendOrder`に情報を送るもので、下記の項目が必要です。

**注意:** * 表記のある場合項目は必須項目です

**VirtusizeOrder**
| **項目**  | **データ形式**                     | **例**        | **詳細**                   |
| ---------------- | -------------------------------------- | ------------------- | ----------------------------------- |
| externalOrderId* | String                                 | "20200601586"       | クライアント様でご使用している注文IDです |
| items*           | `VirtusizeOrderItem`オブジェクトのリスト | 次項の表参照 | 注文商品の詳細リストです |

**VirtusizeOrderItem**

| **項目** | **データ形式** | **例**                             | **詳細**                                            |
| ---------- | --------- | ---------------------------------------- | ------------------------------------------------------------ |
| externalProductId* | String    | "A001"                                   | 商品詳細ページで設定いただいているproductIDと同じもの |
| size*      | String    | "S", "M", etc.                           | サイズ名称                                    |
| sizeAlias  | String    | "Small", "Large", etc.                   | 前述のサイズ名称が商品詳細ページと異なる場合のAlias |
| variantId  | String    | "A001_SIZES_RED"                         | 商品の SKU、色、サイズなどの情報を設定してください。 |
| imageUrl*  | String    | "http[]()://images.example.com/coat.jpg" | 商品画像の URL です。この画像がバーチャサイズのサービスに登録されます。 |
| color      | String    | "RED", "R', etc.                         | 商品の色を設定してください。                          |
| gender     | String    | "W", "Women", etc.                       | 性別を設定してください。                     |
| unitPrice* | Float    | 5100.00                                  | 最大12桁の商品単価を設定してください。 |
| currency*  | String    | "JPY", "KRW", "USD", etc.                | 通貨コードを設定してください。                                 |
| quantity*  | Int       | 1                                        | 購入数量を設定してください。 |
| url        | String    | "http[]()://example.com/products/A001"   | 商品ページのURLを設定してください。一般ユーザーがアクセス可能なURLで設定が必要です。 |

**例**

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



#### 3. 注文情報の送信

ユーザーが注文完了時、view controller内で`Virtusize.sendOrder`を呼び出してください。 

`onSuccess`と`onError`はオプション項目です。

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
