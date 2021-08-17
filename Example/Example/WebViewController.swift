//
//  WebViewController.swift
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
import Virtusize

fileprivate final class ProcessPool: WKProcessPool {
	static let shared = ProcessPool()
}

class WebViewController: UIViewController {

	private var webView: VirtusizeWebView?

	public convenience init() {
		self.init(nibName: nil, bundle: nil)
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		let webView = VirtusizeWebView(frame: .zero) { configuration in
			// set the configuration here
			// Optional: Set up a shared WKProcessPool to allow cookie sharing.
			configuration.processPool = ProcessPool.shared
		}
		webView.uiDelegate = self
		webView.navigationDelegate = self
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

		webView.load(
			URLRequest(
				url: URL(
					string: "https://virtusize-jp-demo.s3-ap-northeast-1.amazonaws.com/sns-auth-test/index.html")!
			)
		)
	}
}

extension WebViewController: WKUIDelegate {
	func webView(
		_ webView: WKWebView,
		createWebViewWith configuration: WKWebViewConfiguration,
		for navigationAction: WKNavigationAction,
		windowFeatures: WKWindowFeatures
	) -> WKWebView? {
		print("WebViewController: createWebViewWith")
		return nil
	}

	func webViewDidClose(_ webView: WKWebView) {
		print("WebViewController: webViewDidClose")
	}
}

extension WebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		print("WebViewController: didFinish")
	}

	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationResponse: WKNavigationResponse,
		decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
	) {
		print("WebViewController: decidePolicyFor")
		decisionHandler(.allow)
	}
}
