//
//  AuthViewController.swift
//  VirtusizeAuthExample
//
//  Copyright (c) 2021-present Virtusize KK
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
import VirtusizeAuth

class AuthViewController: UIViewController {

    // Method 1: Use the VirtusizeWebView
    //	private var webView: VirtusizeWebView!
    // Method 2: Use WKWebView
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Method 1: Use the VirtusizeWebView
//		webView = VirtusizeWebView(frame: .zero) { configuration in
//			// access the WKWebViewConfiguration object here to customize it
//
//			// If you want to allow cookie sharing between multiple VirtusizeWebViews,
//			// assign the same WKProcessPool object to configuration.processPool
//			configuration.processPool = WKProcessPool()
//		}

        // Method 2: Use WKWebView
		webView = WKWebView(frame: .zero)
		webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
		// Required for Google SDK to work in WebView, see https://stackoverflow.com/a/73152331
		webView.customUserAgent = VirtusizeAuthConstants.userAgent

		//
		// Common for both methods
		webView.uiDelegate = self
        webView.navigationDelegate = self

		// For debugging purpose. Should be removed for Production builds or warpped with #if DEBUG
		if #available(iOS 16.4, *) {
			webView.isInspectable = true
		}

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Method 2: Use WKWebView
        webView.load(URLRequest(url: URL(string: "https://demo.virtusize.com")!))
    }
}

// Method 2: Use WKWebView
extension AuthViewController: WKUIDelegate {
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
			// swiftlint:disable:next line_length
            // By default, the Google sign-in page shows a 403 error: disallowed_useragent if you are visiting it within a web view.
            // By setting up the user agent, Google recognizes the web view as a Safari browser
            configuration.applicationNameForUserAgent = "CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"
            let popupWebView = WKWebView(frame: webView.frame, configuration: configuration)

            // For debugging purpose. Should be removed for Production builds or warpped with #if DEBUG
            if #available(iOS 16.4, *) {
				popupWebView.isInspectable = true
			}
            popupWebView.uiDelegate = self
			popupWebView.navigationDelegate = self
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

        return nil
    }

    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
}

// Method 2: Use WKWebView
extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.virtusizeSNSEnabled = true;")
    }
}
