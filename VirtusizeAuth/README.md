# VirtusizeAuth Setup Guide for SNS Authentication

The SNS authentication flow requires switching to a SFSafariViewController, which will load a web page for the user to login with their SNS account. A custom URL scheme must be defined to return the login response to your app from a SFSafariViewController.

### Step 1: Register a URL type

In Xcode, click on your project's **Info** tab and select **URL Types**.

Add a new URL type and set the URL Schemes and identifier to `com.your-company.your-app.virtusize`

![Screen Shot 2021-11-10 at 21 36 31](https://user-images.githubusercontent.com/7802052/141114271-373fb239-91f8-4176-830b-5bc505e45017.png)

### Step 2: Set up application callback handler

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


### ❗IMPORTANT

1. The URL type must include your app's bundle ID and **end with .virtusize**.
2. If you have multiple app targets, add the URL type for all of them.



# Enable SNS Login in Virtusize for Native Webview Apps

Use either of the following methods to enable Virtusize SNS login in WebView

## Method 1: Use the VirtusizeWebView

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

## Method 2: Use WKWebView

### Step 1: Set `javaScriptCanOpenWindowsAutomatically` to true

```swift
yourWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
```

### Step 2: Set `customUserAgent` to ensure Google SDK works within WebView

```swift
yourWebView.customUserAgent = "Mozilla/5.0 AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1"
```

### Step 3: Make sure your view controller confirms the `WKNavigationDelegate` and implement the code below to enable SNS buttons in Virtusize

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

### Step 4: Make sure your view controller confirms the `WKUIDelegate` and implement the code below

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