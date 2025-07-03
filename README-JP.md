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

Read more about Virtusize at [https://www.virtusize.jp](https://www.virtusize.jp/)

You need a unique API key and an Admin account, only available to Virtusize customers. [Contact our sales team](mailto:sales@virtusize.com) to become a customer.

> This is the integration script for native iOS devices only. For web integration, refer to the developer documentation on https://developers.virtusize.com



## Table of Contents

- [対応バージョン](#対応バージョン)
- [はじめに](#installation)
  - [CocoaPods](#cocoapods)
  - [Swift Package Manager](#swift-package-manager)
  - [Carthage](#carthage)
- [セットアップ](#setup)
  - [はじめに](#1-はじめに)
  - [Load Product with Virtusize SDK](#2-load-product-with-virtusize-sdk)
  - [Enable SNS Auentication](#3-enable-sns-auentication)
  - [VirtusizeMessageHandlerの実装（オプション）](#4-virtusizemessagehandlerの実装オプション)
  - [クッキー共有の許可（オプション）](#5-クッキー共有の許可オプション)
  - [製品データチェックを聞く（オプション）](#6-製品データチェックを聞くオプション)
- [Virtusize Views](#virtusize-views)
  - [バーチャサイズ・ボタン（Virtusize Button）](#1-バーチャサイズボタンvirtusize-button)
  - [バーチャサイズ・インページ（Virtuzie InPage）](#2-バーチャサイズインページvirtuzie-inpage)
    - [InPage Standard](#2-inpage-standard)
    - [InPage Mini](#3-inpage-mini)
- [The Order API](#the-order-api)
  - [初期化](#1-初期化)
  - [注文データ向けに*VirtusizeOrder* オブジェクトを作成](#2--注文データ向けにvirtusizeorder-オブジェクトを作成)
  - [注文情報の送信](#3-注文情報の送信) 
- [Enable SNS Login in Virtusize for native Webview apps](#enable-sns-login-in-virtusize-for-native-webview-apps)
- [Build](#build)
- [Run all tests](#run-all-tests)
- [Roadmap](#roadmap)
- [License](#license)



## 対応バージョン

- iOS 13.0+
- Xcode 12+
- Swift 5.0+



## はじめに

If you'd like to continue using the older Version 1.x.x, refer to the branch [v1](https://github.com/virtusize/integration_ios/tree/v1).

### CocoaPods

[CocoaPods](https://cocoapods.org/) dependency managerをインストールして使用します。下記のコマンドでインストールが可能です。

```bash
$ gem install cocoapods
```

Virtusize SDKをXcodeのCocosPodsを使ってプロジェクトに実装する際、`Podfile`にて下記コードをご利用ください。

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target '<your-target-name>' do
pod 'Virtusize', '~> 2.12.2'
end
```

その後、下記のコマンドを実行してください。

```bash
$ pod install
```



### Swift Package Manager

Starting with the `2.3.1` release, Virtusize supports installation via [Swift Package Manager](https://swift.org/package-manager/)

1. In Xcode, select **File** > **Swift Packages** > **Add Package Dependency...** and enter `https://github.com/virtusize/integration_ios.git` as the repository URL.
2. Select a minimum version of `2.12.2`
3. Click **Next**



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

### 1. はじめに

Virtusizeのプロパティをアプリのdelegateの`application(_:didFinishLaunchingWithOptions:)`に設定します。

``` Swift
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
        .build()

    return true
}
```

環境は、実装をしている環境を選択してください `.STAGING`,  `.GLOBAL`, `.JAPAN` ,もしくは`.KOREA`から選択できます。

**VirtusizeParamsBuilder**を使用して実装構成を変更することにより、`Virtusize.params`をセットアップできます。可能な構成方法を次の表に示します。

**VirtusizeParamsBuilder**

| 項目                 | データ形式                          | 例                                                           | 説明                                                         | 要件                                                         |
| -------------------- | ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| setLanguage          | VirtusizeLanguage                   | setLanguage(.JAPANESE)                                       | 実装する際に使用する初期言語をセットします。選択可能言語は以下：`VirtusizeLanguage.ENGLISH`, `VirtusizeLanguage.JAPANESE` および `VirtusizeLanguage.KOREAN` | 特になし。デフォルトでは、初期言語はVirtusizeの環境に基づいて設定されます。 |
| setShowSGI           | Boolean                             | setShowSGI(true)                                             | ユーザーが生成したアイテムをワードローブに追加する方法として、SGIを取得の上、SGIフローを使用するかどうかを決定します。 | 特になし。デフォルトではShowSGIはfalseに設定されています。   |
| setAllowedLanguages  | `VirtusizeLanguage`列挙のリスト     | setAllowedLanguages([VirtusizeLanguage.ENGLISH, VirtusizeLanguage.JAPANESE]) | ユーザーが言語選択ボタンより選択できる言語                   | 特になし。デフォルトでは、英語、日本語、韓国語など、表示可能なすべての言語が表示されるようになっています。 |
| setDetailsPanelCards | `VirtusizeInfoCategory`列挙のリスト | setDetailsPanelCards([VirtusizeInfoCategory.BRANDSIZING, VirtusizeInfoCategory.GENERALFIT]) | 商品詳細タブに表示する情報のカテゴリ。表示可能カテゴリは以下： `VirtusizeInfoCategory.MODELINFO`, `VirtusizeInfoCategory.GENERALFIT`, `VirtusizeInfoCategory.BRANDSIZING` および `VirtusizeInfoCategory.MATERIAL` | 特になし。デフォルトでは、商品詳細タブに表示可能なすべての情報カテゴリが表示されます。 |
| setShowSNSButtons | Boolean | setShowSNSButtons(true)| Determines whether the integration will show SNS buttons | No. By default, ShowSNSButtons is set to true |


### 2. Load Product with Virtusize SDK

In the view controller for your product page, you will need to use `Virtusize.load` to populate the Virtusize views:

- Create a `VirtusizeProduct` object with:
	- An `exernalId` that will be used to reference the product in the Virtusize server
	- An `imageURL`  for the product image
- Pass the `VirtusizeProduct` object to the `Virtusize.load` method

``` Swift
override func viewDidLoad() {
    super.viewDidLoad()

	// Declare a `VirtusizeProduct variable, which will be passed to the `Virtusize` views in order to bind the product info
	let product = VirtusizeProduct(
		// Set the product's external ID
		externalId: "vs_dress",
		// Set the product image URL
		imageURL: URL(string: "http://www.example.com/image.jpg")
	)

	/// Load the product in order to populate the `Virtusize` views
	Virtusize.load(product: product)
}
```

### 3. SNS認証を有効にする

SNS認証フローでは、ユーザーがSNSアカウントでログインできるように、`SFSafariViewController`を使って認証用の に切り替えてユーザーがSNSアカウントでログインするためのWebページを表示します。読み込みます。ログイン後、`SFSafariViewController` からアプリに戻すためには、カスタムURLスキームを定義するしておく必要があります。

#### ステップ1: URLタイプを登録する

Xcodeで、プロジェクトの **Info** タブをクリックし、**URL Types** を選択します。

新しいURLタイプを追加し、URL Schemes と identifier の両方にを、 `com.your-company.your-app.virtusize` をに設定してくださいします。

![Screen Shot 2021-11-10 at 21 36 31](https://user-images.githubusercontent.com/7802052/141114271-373fb239-91f8-4176-830b-5bc505e45017.png)

#### ステップ2: アプリケーションのコールバックハンドラーを設定する

古いプロジェクトの場合、AppDelegate の `application(_:open:options)` メソッドを実装します：

```Swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return Virtusize.handleUrl(url)
}
```

新しいプロジェクトでは、SceneDelegate の `scene(_:openURLContexts)` メソッドを実装します：

```Swift
func scene(_ scene: UIScene, openURLContexts: Set<UIOpenURLContext>) {
    if let urlContext = openURLContexts.first {
        _ = Virtusize.handleUrl(urlContext.url)
    }
}
```

`AppDelegate` と `SceneDelegate` の両方のファイルがある場合、SNSコールバックの処理には `SceneDelegate` を使用してください。

#### ❗重要

1. URLタイプには、アプリのバンドルIDが含まれ、**末尾に `.virtusize` を付ける必要があります**。
2. 複数のアプリターゲットがある場合は、すべてにURLタイプを追加してください。


#### (オプション) カスタムブランチを設定する

WebViewで読み込むURLを更新することで、カスタムの環境ブランチをテストできます：

```Swift
let url = VirtusizeBranch.applyBranch(
    to: URL(string: "https://demo.virtusize.com")!,
    branch: "branch-name")
webView.load(URLRequest(url: url))
```

### ネイティブWebViewアプリでVirtusizeのSNSログインを有効にする

VirtusizeのSNSログインをWebView内で有効にするには、以下のいずれかの方法を実装 使用してください。

#### 方法1: VirtusizeWebViewを使用する

#### Virtusizeを読み込む`WKWebView`を`VirtusizeWebView`に置き換える

Webビュー内でのVirtusize連携のWeb版において、VirtusizeのSNSログインを有効にするには、以下のメソッドを使用してください。

1. UIを純粋にUIKitで構築している場合は、Swiftファイル内の `WKWebView` を **`VirtusizeWebView`** に置き換えてください。
また、`WKWebViewConfiguration` オブジェクトを使ってWebビューを設定している場合は、以下の例のようにクロージャ内でアクセスしてください。

   - Swift

   ```diff
   - var webView: WKWebView
   + var webView: VirtusizeWebView
   ```

   ```swift
   webView = VirtusizeWebView(frame: .zero) { configuration in
       // WKWebViewConfigurationオブジェクトにアクセスしてカスタマイズ可能
       
       // 複数のVirtusizeWebView間でCookieを共有したい場合
       configuration.processPool = WKProcessPool()
   }
   ```

2. UIをXcodeのInterface Builderで構築している場合は、IdentityインスペクタでWebビューのCustom Classを **`VirtusizeWebView`** に設定してください。

   - Swift

   ```diff
   - @IBOutlet weak var webview: WKWebView!
   + @IBOutlet weak var webview: VirtusizeWebView!
   ```

   - Interface Builder

     ![img](https://user-images.githubusercontent.com/7802052/121308895-87e3b500-c93c-11eb-8745-f4bf22bccdba.png)

#### 方法2: WKWebViewを使用する

#### ステップ1: `javaScriptCanOpenWindowsAutomatically` をtrueに設定

```swift
yourWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
```

#### ステップ2: Google SDKが動作するように `customUserAgent` を設定

```swift
yourWebView.customUserAgent = VirtusizeAuthConstants.userAgent
```

#### ステップ3: ViewController が `WKNavigationDelegate` に準拠していることを確認し、SNSログインボタンを有効にする処理化コードを実装

```swift
class YourViewController: UIViewController {
    
    private var yourWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ... その他のコード
        
        yourWebView.navigationDelegate = self
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.virtusizeSNSEnabled = true;")
    }
}
```

#### ステップ4: ViewController が`WKUIDelegate` に準拠していることを確認し、以下のコードを実装

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
            // デフォルトでは、GoogleのサインインページはWebビュー内でアクセスすると 403エラー：disallowed_useragent を表示します。
            // User Agent を設定することで、GoogleはWebビューをSafariブラウザとして認識します。
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
        
        // 残りのコードはそのままで構いません。
        
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
}
```

### マイグレーションガイド（バージョン2.x → 2.8.0）

#### ステップ1: AppDelegate または SceneDelegate にコールバックURLハンドラを設定

```Swift
// 古いアプリ - SceneDelegate が使われていない場合は AppDelegate に追加
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return Virtusize.handleUrl(url)
}
```

```Swift
// 新しいアプリ - SceneDelegate を更新
func scene(_ scene: UIScene, openURLContexts: Set<UIOpenURLContext>) {
    if let urlContext = openURLContexts.first {
        _ = Virtusize.handleUrl(urlContext.url)
    }
}
```

#### ステップ2: `setAppBundleId` 関数呼び出しを削除

```diff
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
  // Virtusize の初期化は省略
-   VirtusizeAuth.setAppBundleId("com.your-company.your-app")
  return true
}
```

#### ステップ3: (オプション) ネイティブWebViewアプリでは `customUserAgent` を設定


```swift
// yourWebViewがWKWebViewの場合
yourWebView.customUserAgent = VirtusizeAuthConstants.userAgent
```

### 4. VirtusizeMessageHandlerの実装（オプション）

`VirtusizeMessageHandler`プロトコルには2つの必須メソッドがあります。

- `virtusizeController(_:didReceiveError:)`はコントローラがネットワークエラーやデシリアライズエラーを報告する際に呼び出されます。
- `virtusizeController(_:didReceiveEvent:)`はコントローラとVirtusize APIの間でデータが交換されたときに呼び出されます。`VirtusizeEvent`は必須の名前（`name`）とオプションのデータ（`data`）プロパティを持つ構造体（`struct`）です。

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



### 5. クッキー共有の許可（オプション）

`VirtusizeWebViewController` はオプションで `processPool:WKProcessPool` パラメーターを受け取り、クッキーの共有を許可します。

```Swift
// Optional: Set up WKProcessPool to allow cookie sharing.
Virtusize.processPool = WKProcessPool()
```



### 6. 製品データチェックを聞く（オプション）

ボタンが `externalId` で初期化されると、SDK は製品が解析されてデータベースに追加されたかどうかをチェックするために API を呼び出します。

そのAPIコールをデバッグするために、`NotificationCenter`をサブスクライブし、2つの`Notification.Name`エイリアスを観ることができます。

- `Virtusize.productCheckDidFai`lは、失敗の原因を持つメッセージを含む`UserInfo`を受け取ります。
- `Virtusize.productCheckDidSucceed`は、呼び出しが成功した場合に送信されます。

チェックに失敗した場合は、ボタンが非表示になります。

サンプルプロジェクトでは、可能な実装を1つ確認することができます。



## Virtusize Views

SDKをセットアップした後、`VirtusizeView`を追加して、顧客が理想的なサイズを見つけられるようにします。Virtusize SDKはユーザーが使用するために2つの主要なUIコンポーネントを提供します。:



### 1. バーチャサイズ・ボタン（Virtusize Button）

#### (1) はじめに

VirtusizeButtonはこのSDKの中でもっとシンプルなUIのボタンです。ユーザーが正しいサイズを見つけられるように、ウェブビューでアプリケーションを開きます。



#### (2) デフォルトスタイル

SDKのVirtusizeボタンには2つのデフォルトスタイルがあります。

|                          Teal Theme                          |                         Black Theme                          |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/7802052/92671785-22817a00-f352-11ea-8ce9-6b4f7fcb43c4.png" /> | <img src="https://user-images.githubusercontent.com/7802052/92671771-172e4e80-f352-11ea-8443-dcb8b05f5a07.png" /> |

もしご希望であれば、ボタンのスタイルもカスタマイズすることができます。



#### (3) 使用方法

**A. Virtusizeボタンの追加**

- ストアの商品商品ページでVirtusize Buttonを使用するには、以下の方法があります。

  - XcodeのInterface Builder StoryboardでUIButtonを作成し、Identity inspectorでCustom Classを`VirtusizeButton`に設定し、読み込んでいる時にはボタンが非表示になるようにします。

    <img src="https://user-images.githubusercontent.com/7802052/92836674-a487a680-f417-11ea-81d0-5aa32390167a.png" style="zoom:70%;" />

  - もしくはプログラムでVirtusizeButtonを追加します

    ```swift
    let virtusizeButton = VirtusizeButton()
    view.addSubview(virtusizeButton)
    ```

  - バーチャサイズのデフォルトスタイルを使用するために、VirtusizeButtonのプロパティスタイルを`VirtusizeViewStyle.TEAL`または`VirtusizeViewStyle.BLACK`として設定してください。

    ```swift
    virtusizeButton.style = .TEAL
    ```

  - また、ボタンのスタイル属性をカスタマイズすることもできます。たとえば、タイトルラベルのテキスト、高さ、幅などです。

**B. Connect the Virtusize button, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`)  **into the Virtusize API  by using the  `Virtusize.setVirtusizeView` method.**

```swift
Virtusize.setVirtusizeView(self, virtusizeButton, product: product)
```



### 2. **バーチャサイズ・インページ（Virtuzie InPage）**

#### (1) はじめに

Virtusize InPageは、私たちのサービスのスタートボタンのような役割を果たすボタンです。また、このボタンは、お客様が正しいサイズを見つけるためのフィッティングガイドとしても機能します。

##### **InPageの種類**

Virtusize SDKには2種類のInPageがあります。

|                       InPage Standard                        |                         InPage Mini                          |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![InPageStandard](https://user-images.githubusercontent.com/7802052/92671977-9cb1fe80-f352-11ea-803b-5e3cb3469be4.png) | ![InPageMini](https://user-images.githubusercontent.com/7802052/92671979-9e7bc200-f352-11ea-8594-ed441649855c.png) |

⚠️**注意事項**⚠️

1. InPageはVirtusizeボタンと一緒に導入することはできません。オンラインショップでは、InPageかVirtusizeボタンのどちらかをお選びください。
2. InPage Miniは、必ずInPage Standardと組み合わせてご利用ください。



#### (2) InPage Standard

##### A. 使用方法

- **VirtusizeInPageStandardの追加**

  - Virtusize InPage Standardをサイトの商品詳細ページで利用する場合は以下が可能：

    - XcodeのInterface Builderで*UIView*を作成し、Identity inspectorでCustom Classを`VirtusizeInPageStandard`に設定し、読み込んでいる時にはビューが非表示になるようにします。

      <img src="https://user-images.githubusercontent.com/7802052/92836755-ba956700-f417-11ea-8fb4-e9d9e2291031.png" style="zoom:70%;" />

      動的な高さをコンテンツに依存させるためには、必ずInPage Standardの制約を設定してから、サイズインスペクタ（*the Size inspector*）→固有サイズ（*Intrinsic Size*）の検索→プレースホルダー（*Placeholder*）の選択を行ってください。

      

      <img src="https://user-images.githubusercontent.com/7802052/92836828-ce40cd80-f417-11ea-94a7-999cb3e063a4.png" style="zoom:70%;" />

    - もしくは、Virtusize InPage Standardをプログラム的に追加:

      ```swift
      let inPageStandard = VirtusizeInPageStandard()
      view.addSubview(inPageStandard)
      ```

  - バーチャサイズのデフォルトスタイルを使用するために、VirtusizeInPageStandardのプロパティスタイルを`VirtusizeViewStyle.TEAL`または`VirtusizeViewStyle.BLACK`として設定してください。

    CTAボタンの背景色を変更したい場合は、`inPageStandardButtonBackgroundColor`プロパティを使用して色を設定できます。

    ```swift
    // Set the InPage Standard style to VirtusizeStyle.BLACK
    inPageStandard.style = .BLACK
    // Set the background color of the CTA button to UIColor.blue
    inPageStandard.inPageStandardButtonBackgroundColor = UIColor.blue
    ```

    ```swift
    // Set the InPage Standard style to VirtusizeStyle.TEAL
    inPageStandard.style = .TEAL
    // Set the background color of the CTA button to a custom color usign ColorLiteral
    inPageStandard.inPageStandardButtonBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    ```

  - VirtusizeInPageStandardをプログラムで追加し、アプリ画面の端とVirtusizeInPageStandardの間に水平方向の余白を設定したい場合は、`setHorizontalMargin`を使用します。

    InPage Standardに直接幅を設定したい場合は、auto layout constraintsを使用します。

    ```swift
    // Set the horizontal margins to 16
    inPageStandard.setHorizontalMargin(view: view, margin: 16)
    
    // Or set the direct width for InPage Standard programtically
    inPageStandard.translatesAutoresizingMaskIntoConstraints = false
    inPageStandard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inPageStandard.widthAnchor.constraint(equalToConstant: 350).isActive = true
    ```

  - InPage Standardのフォントサイズを変更したい場合は、`messageFontSize`と`buttonFontSize`のプロパティを利用できます。

    ```swift
    inPageStandard.buttonFontSize = 12
    inPageStandard.messageFontSize = 12
    ```

- **Connect the Virtusize InPage Standard, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`)  **into the Virtusize API  by using the  `Virtusize.setVirtusizeView` method.**

```swift
Virtusize.setVirtusizeView(self, inPageStandard, product: product)
```



##### B. デザインガイドライン

- ##### デフォルトデザイン

  デフォルトデザインは2種類あります。

  |                          Teal Theme                          |                         Black Theme                          |
  | :----------------------------------------------------------: | :----------------------------------------------------------: |
  | ![InPageStandardTeal](https://user-images.githubusercontent.com/7802052/92672035-b9e6cd00-f352-11ea-9e9e-5385a19e96da.png) | ![InPageStandardBlack](https://user-images.githubusercontent.com/7802052/92672031-b81d0980-f352-11ea-8b7a-564dd6c2a7f1.png) |

- ##### **レイアウトのバリエーション**

  設定可能なレイアウト例

  |               1 thumbnail + 2 lines of message               |              2 thumbnails + 2 lines of message               |
  | :----------------------------------------------------------: | :----------------------------------------------------------: |
  | ![1 thumbnail + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399368-5e879300-1930-11eb-8b77-b49e06813550.png) | ![2 thumbnails + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399370-5f202980-1930-11eb-9a2d-7b71714aa7b4.png) |
  |             **1 thumbnail + 1 line of message**              |        **2 animated thumbnails + 2 lines of message**        |
  | ![1 thumbnail + 1 line of message](https://user-images.githubusercontent.com/7802052/97399373-5f202980-1930-11eb-81fe-9946b656eb4c.png) | ![2 animated thumbnails + 2 lines of message](https://user-images.githubusercontent.com/7802052/97399355-59c2df00-1930-11eb-8a52-292956b8762d.gif) |

- ##### **推奨設定箇所**

  - サイズテーブルの近く

  - サイズ情報掲載箇所

    <img src="https://user-images.githubusercontent.com/7802052/92672185-15b15600-f353-11ea-921d-397f207cf616.png" style="zoom:50%;" />

- ##### **UI カスタマイゼーション**

  - **変更可:**
    - CTAボタンの背景色（[WebAIM contrast test](https://webaim.org/resources/contrastchecker/)で問題がなければ）
    - Inpageの横幅（アプリの横幅に合わせて変更可）
  - **変更不可:**
    - 形状やスペースなどのインターフェイスコンポーネント
    - フォント
    - CTA ボタンの形状
    - テキスト文言
    - ボタンシャドウ（削除も不可）
    - VIRTUSIZE ロゴと プライバシーポリシーのテキストが入ったフッター（削除も不可）



#### (3) InPage Mini

こちらは、InPageのミニバージョンで、アプリに配置することができます。目立たないデザインなので、お客様が商品画像やサイズ表を閲覧するようなレイアウトに適しています。

##### A. 使用方法

- **VirtusizeInPageMiniの追加**

  - Virtusize InPage Miniをサイトの商品詳細ページで利用する場合は以下が可能：

    - XcodeのInterface Builderで*UIView*を作成し、Identity inspectorでCustom Classを`VirtusizeInPageMini`に設定し、読み込んでいる時にはビューが非表示になるようにします。

      <img src="https://user-images.githubusercontent.com/7802052/92836772-bf5a1b00-f417-11ea-9ef3-03a9079a7834.png" style="zoom:70%;" />

      動的な高さをコンテンツに依存させるためには、必ずInPage Miniの制約を設定してから、サイズインスペクタ（*the Size inspector*）→固有サイズ（*Intrinsic Size*）の検索→プレースホルダー（*Placeholder*）の選択を行ってください。

      <img src="https://lh3.googleusercontent.com/wARRXwn4a7tHe4wSzqkqCmlAeVRzQSObBpHPU0G0UAYGjLen0laqc325pmoaxadXFcuzvCnDT9R3jhtq42SKF21KgcRkOQU7OkCdMXm9wGdmzPCDyyk9y9CuOmVJTG8co0_-E4QR" style="zoom:70%;" />

    - もしくは、Virtusize InPage Miniをプログラム的に追加:

      ```swift
      let inPageMini = VirtusizeInPageMini()
      view.addSubview(inPageMini)
      ```

  - バーチャサイズのデフォルトスタイルを使用するために、VirtusizeInPageMiniのプロパティスタイルを`VirtusizeViewStyle.TEAL`または`VirtusizeViewStyle.BLACK`として設定してください。

    バーの背景色を変更したい場合は、`inPageMiniBackgroundColor`プロパティで色を設定します。

    ```swift
    inPageMini.style = .TEAL
    inPageMini.inPageMiniBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    ```

  - VirtusizeInPageMiniをプログラムで追加し、アプリ画面の端とVirtusizeInPageMiniの間に水平方向の余白を設定したい場合は、`setHorizontalMargin`を使用します。

    InPage Miniに直接幅を設定したい場合は、auto layout constraintsを使用します。

    ```swift
    // Set the horizontal margins to 16
    inPageMini.setHorizontalMargin(view: view, margin: 16)
    
    // Or set the direct width for InPage Standard programtically
    inPageMini.translatesAutoresizingMaskIntoConstraints = false
    inPageMini.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inPageMini.widthAnchor.constraint(equalToConstant: 350).isActive = true
    ```

  - InPage Miniのフォントサイズを変更したい場合は、`messageFontSize`と`buttonFontSize`のプロパティを利用できます。

    ```swift
    inPageMini.messageFontSize = 12
    inPageMini.buttonFontSize = 10
    ```

- **Connect the Virtusize InPage Mini, along with the** `VirtusizeProduct` **object (which you have passed to ** `Virtusize.load`)  **into the Virtusize API  by using the  `Virtusize.setVirtusizeView` method.**

  ```swift
  Virtusize.setVirtusizeView(self, inPageMini, product: product)
  ```



##### B. **デザインガイドライン**

- ##### デフォルト デザイン

  ２種類のでフォルトデザインを用意しています。

  |                          Teal Theme                          |                         Black Theme                          |
  | :----------------------------------------------------------: | :----------------------------------------------------------: |
  | ![InPageMiniTeal](https://user-images.githubusercontent.com/7802052/92672234-2d88da00-f353-11ea-99d9-b9e9b6aa5620.png) | ![InPageMiniBlack](https://user-images.githubusercontent.com/7802052/92672232-2c57ad00-f353-11ea-80f6-55a9c72fb0b5.png) |

- ##### **推奨設置箇所**

  |                 Underneath the product image                 |              Underneath or near the size table               |
  | :----------------------------------------------------------: | :----------------------------------------------------------: |
  | <img src="https://user-images.githubusercontent.com/7802052/92672261-3c6f8c80-f353-11ea-995c-ede56e0aacc3.png" /> | <img src="https://user-images.githubusercontent.com/7802052/92672266-40031380-f353-11ea-8f63-a67c9cf46c68.png" /> |

- ##### デフォルトのフォント

  - **日本語**
    - Noto Sans CJK JP
    - 12pt (メッセージ文言)
    - 10pt (ボタン内テキスト)
  - **韓国語**
    - Noto Sans CJK KR
    - 12pt (メッセージ文言)
    - 10pt (ボタン内テキスト)
  - **英語**
    - San Francisco (System Default)
    - 14pt (メッセージ文言)
    - 12pt (ボタン内テキスト)

- ##### UI カスタマイゼーション

  - **変更可:**
    - CTAボタンの背景色（[WebAIM contrast test](https://webaim.org/resources/contrastchecker/)で問題がなければ）
  - **変更不可:**
    - フォント
    - CTA ボタンの形状
    - テキスト文言



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
| **項目** | **データ形式**                     | **例**        | **詳細**                   |
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



## Enable SNS Login in Virtusize for Native Webview Apps

Use the [Virtusize Auth SDK](https://github.com/virtusize/virtusize_auth_ios)



## Build

You need to install [SwiftLint](https://github.com/realm/SwiftLint).

    make build



## Run all tests

    make test



## Roadmap

Please check the [Roadmap](ROADMAP.md) to find upcoming features and expected release dates.



## License

Copyright (c) 2018-21 Virtusize CO LTD (https://www.virtusize.jp)
