//
//  VirtusizeWebViewController.swift
//
//  Copyright (c) 2018-20 Virtusize KK
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import WebKit

/// The methods of this protocol notify you with Virtusize specific messages such as errors as
/// `VirtusizeError` and events as `VirtusizeEvent` and tell you when to dismiss the view controller
public protocol VirtusizeMessageHandler: class {
    func virtusizeController(_ controller: VirtusizeWebViewController, didReceiveError error: VirtusizeError)
    func virtusizeController(_ controller: VirtusizeWebViewController, didReceiveEvent event: VirtusizeEvent)
    func virtusizeControllerShouldClose(_ controller: VirtusizeWebViewController)
}

/// This `UIViewController` represents the Virtusize Window
public final class VirtusizeWebViewController: UIViewController {
    public weak var delegate: VirtusizeMessageHandler?

    private var webView: WKWebView?
    private var popupWebView: WKWebView?

    // Allow process pool passing to share cookies
    private var processPool: WKProcessPool?

    private static let cookieBidKey = "virtusize.bid"

    public convenience init?(
        handler: VirtusizeMessageHandler? = nil,
        processPool: WKProcessPool? = nil
    ) {
        self.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.delegate = handler
        self.processPool = processPool

        guard Virtusize.product?.productCheckData != nil else {
            reportError(error: .invalidProduct)
            return nil
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let contentController = WKUserContentController()
        contentController.add(self, name: "eventHandler")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        if let processPool = self.processPool {
            config.processPool = processPool
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        self.webView = webView

        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let layoutGuide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
                webView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
            ])
        } else {
            let views = ["webView": webView]
            let verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-20-[webView]-0-|",
                options: .alignAllTop,
                metrics: nil,
                views: views)
            let horizontalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[webView]-0-|",
                options: .alignAllLeft,
                metrics: nil,
                views: views)

            NSLayoutConstraint.activate(verticalConstraints + horizontalConstraints)
        }

        // If the request is invalid, the controller should be dismissed
        guard let request = APIRequest.virtusizeURL(region: Virtusize.params?.region) else {
            reportError(error: .invalidRequest)
            return
        }
        webView.load(request)
    }

    // MARK: Rotation Lock
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    // MARK: Error Handling
    public func reportError(error: VirtusizeError) {
        delegate?.virtusizeController(self, didReceiveError: error)
    }

    // MARK: Closing view
    @objc internal func shouldClose() {
        delegate?.virtusizeControllerShouldClose(self)
    }
}

extension VirtusizeWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let vsParamsFromSDKScript = Virtusize.params?.getVsParamsFromSDKScript() else {
            reportError(error: .invalidVsParamScript)
            return
        }
        webView.evaluateJavaScript(vsParamsFromSDKScript, completionHandler: nil)
        checkAndUpdateBrowserID()
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error) {
        // The error is caused by canceling the current load that is not finished yet
        // We should ignore this error. Otherwise, the webview will be closed automatically
        if error._code == NSURLErrorCancelled {
            return
        }
        reportError(error: VirtusizeError.navigationError(error))
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error) {
        reportError(error: VirtusizeError.navigationError(error))
    }

    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }

        if isExternalLinks(url: url.absoluteString) {
            if let sharedApplication = UIApplication.safeShared {
                sharedApplication.safeOpenURL(url)
                return nil
            }
        }

        // swiftlint:disable line_length
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            // By default, The Google sign-in page shows a 403 error: disallowed_useragent if you are visiting it within a Webview.
            // By setting up the user agent, Google recognizes the web view as a Safari browser
            configuration.applicationNameForUserAgent = "Version/10.0 Safari/604.1"
            popupWebView = WKWebView(frame: self.view.frame, configuration: configuration)
            popupWebView!.navigationDelegate = self
            popupWebView!.uiDelegate = self
            self.view.addSubview(popupWebView!)
            return popupWebView
        }
        return nil
    }

    /// Checks if a URL is an external link to be open on the Safari browser
    private func isExternalLinks(url: String?) -> Bool {
        return url != nil && (url!.contains("survey") || url!.contains("privacy"))
    }

    public func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }

    /// Checks if the bid in the web cookies  is different from the bid saved locally.
    /// If it is, update and store the new bid.
    private func checkAndUpdateBrowserID() {
        if #available(iOS 11.0, *) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies({ cookies in
                for cookie in cookies {
                    if let cookieValue = cookie.properties?[HTTPCookiePropertyKey(rawValue: "Value")] as? String {
                        if cookie.name == VirtusizeWebViewController.cookieBidKey &&
                            cookieValue != BrowserID.current.identifier {
                            BrowserID.current.identifier = cookie.value
                        }
                    }
                }
            })
        } else {
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies
                    where cookie.name == VirtusizeWebViewController.cookieBidKey &&
                        cookie.value != BrowserID.current.identifier {
                            BrowserID.current.identifier = cookie.value
                }
            }
        }
    }
}

extension VirtusizeWebViewController: WKScriptMessageHandler {
    // MARK: - Widget Callbacks
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage) {
        guard message.name == "eventHandler" else {
            return
        }
        do {
            let event = try Deserializer.event(data: message.body)
            if event.name == "user-closed-widget" {
                shouldClose()
            }
            delegate?.virtusizeController(self, didReceiveEvent: event)
        } catch {
            if let error = error as? VirtusizeError {
                reportError(error: error)
            }
        }
    }
}
