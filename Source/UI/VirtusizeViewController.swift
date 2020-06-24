//
//  VirtusizeViewController.swift
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

/// The methods of this protocol notify you with Virtusize specific messages such as errors as
/// `VirtusizeError` and events as `VirtusizeEvent` and tell you when to dismiss the view controller
public protocol VirtusizeMessageHandler: class {
    func virtusizeController(_ controller: VirtusizeViewController, didReceiveError error: VirtusizeError)
	func virtusizeController(_ controller: VirtusizeViewController, didReceiveEvent event: VirtusizeEvent)
    func virtusizeControllerShouldClose(_ controller: VirtusizeViewController)
}

/// This `UIViewController` represents the Fit Illustrator Window
public final class VirtusizeViewController: UIViewController {
	public weak var delegate: VirtusizeMessageHandler?

	private var webView: WKWebView?
    internal var splashView: SplashView =  SplashView()

    private var context: JSONObject = [:]

    // Allow process pool passing to share cookies
    private var processPool: WKProcessPool?

    public convenience init?(
        product: VirtusizeProduct? = nil,
        handler: VirtusizeMessageHandler? = nil,
        processPool: WKProcessPool? = nil
    ) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = handler
        self.processPool = processPool

        guard let context = product?.context else {
            reportError(error: .invalidProduct)
            return nil
        }
        self.context = context
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

        view.addSubview(splashView)
        splashView.cancelButton.addTarget(self, action: #selector(shouldClose), for: .touchUpInside)

        // If the request is invalid, the controller should be dismissed
		guard let request = APIRequest.fitIllustratorURL(in: context) else {
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

extension VirtusizeViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error) {
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

        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
                webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
}

extension VirtusizeViewController: WKScriptMessageHandler {
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

            if !splashView.isHidden,
                event.name == "user-selected-size" || event.name.starts(with: "user-opened-panel") {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: { [weak self] in
                        self?.splashView.alpha = 0
                        }, completion: { [weak self] _ in
                            self?.splashView.isHidden = true
                    })
                }
            }
            delegate?.virtusizeController(self, didReceiveEvent: event)
        } catch {
            if let error = error as? VirtusizeError {
                reportError(error: error)
            }
        }
    }
}
