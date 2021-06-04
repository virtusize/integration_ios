//
//  VirtusizeWebView.swift
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

import WebKit

fileprivate final class VSProcessPool: WKProcessPool {
	static let pool = VSProcessPool()
}

open class VirtusizeWebView: WKWebView {

	open override var uiDelegate: WKUIDelegate? {
		didSet {
			guard uiDelegate?.isEqual(self) == false else {
				return
			}

			wkUIDelegate = uiDelegate
			uiDelegate = self
		}
	}

	private weak var wkUIDelegate: WKUIDelegate?

	public init(frame: CGRect) {
		let configuration = WKWebViewConfiguration()
		configuration.processPool = VSProcessPool.pool
		super.init(frame: frame, configuration: configuration)
		uiDelegate = self
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension VirtusizeWebView: WKUIDelegate {

	open func webView(
		_ webView: WKWebView,
		createWebViewWith configuration: WKWebViewConfiguration,
		for navigationAction: WKNavigationAction,
		windowFeatures: WKWindowFeatures
	) -> WKWebView? {
		guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
			// By default, the Google sign-in page shows a 403 error: disallowed_useragent if you are visiting it within a web view.
			// By setting up the user agent, Google recognizes the web view as a Safari browser
			configuration.applicationNameForUserAgent = "CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"
			let popupWebView = WKWebView(frame: webView.frame, configuration: configuration)
			popupWebView.uiDelegate = self
			webView.addSubview(popupWebView)
			return popupWebView
		}

		return wkUIDelegate?.webView?(
			webView,
			createWebViewWith: configuration,
			for: navigationAction,
			windowFeatures: windowFeatures
		)
	}

	open func webViewDidClose(_ webView: WKWebView) {
		webView.removeFromSuperview()
		wkUIDelegate?.webViewDidClose?(webView)
	}
}
