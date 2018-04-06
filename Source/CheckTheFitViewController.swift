//
//  CheckTheFitViewController.swift
//
//  Copyright (c) 2018 Virtusize AB
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

public protocol CheckTheFitViewControllerDelegate : class {
	func checkTheFitViewController(_ controller: CheckTheFitViewController, didReceiveEvent eventName: String, data: Any?)
    func checkTheFitViewControllerShouldClose(_ controller: CheckTheFitViewController)
}

public final class CheckTheFitViewController : UIViewController, WKScriptMessageHandler {

	public weak var delegate: CheckTheFitViewControllerDelegate?

	private var webView: WKWebView?

	internal var jsonResult: JSONObject?

	public init(virtusizeButton: VirtusizeButton) {
		super.init(nibName: nil, bundle: nil)
		self.jsonResult = virtusizeButton.jsonResult
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white

		let contentController = WKUserContentController()
        contentController.add(self, name: "eventHandler")

		let config = WKWebViewConfiguration()
		config.userContentController = contentController

		let webView = WKWebView(frame: view.bounds, configuration: config)
		webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(webView)
		self.webView = webView

		guard let urlRequest = VirtusizeAPI.fitIllustratorURL(jsonResult: jsonResult) else {
			return
		}
		webView.load(urlRequest)
	}


    // MARK: Widget Callbacks

	public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard message.name == "eventHandler" else {
			return
		}
		guard let body = message.body as? [String: Any] else {
			print("Malformed event payload")
			return
		}
		guard let eventName: String = body["name"] as? String else {
			print("Event payload does not contain a value for 'name'")
			return
		}

		if eventName == "user-closed-widget" {
			delegate?.checkTheFitViewControllerShouldClose(self)
		}

		let eventData: Any? = body["data"]

		delegate?.checkTheFitViewController(self, didReceiveEvent: eventName, data: eventData)
	}


	// MARK: Rotation Lock

	public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}

}

