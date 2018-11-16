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
    func checkTheFitViewController(_ controller: CheckTheFitViewController, didReceiveError error: Error)
}

public enum CheckTheFitError: Error {
    case deserializationError, encodingError, invalidPayload, invalidRequest, navigationError(Error)
}

extension CheckTheFitError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .invalidRequest:
            return "CheckTheFit: Invalid Request - Malformed query"
        case .deserializationError:
            return "CheckTheFit: Failed to deserialize given event payload"
        case .encodingError:
            return "CheckTheFit: Failed to convert given string to UTF-8 data"
        case .invalidPayload:
            return "CheckTheFit: Event payload does not contain a value for 'name'"
        case .navigationError(let error):
            return "CheckTheFit: Navigation blocked – \(error)"
        }
    }
}

public final class CheckTheFitViewController : UIViewController {

	public weak var delegate: CheckTheFitViewControllerDelegate?

	private var webView: WKWebView?
    internal var splashView: SplashView =  SplashView()

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

		let webView = WKWebView(frame: .zero, configuration: config)
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
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[webView]-0-|", options: .alignAllTop, metrics: nil, views: views)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[webView]-0-|", options: .alignAllLeft, metrics: nil, views: views)
            
			NSLayoutConstraint.activate(verticalConstraints + horizontalConstraints)
		}

        view.addSubview(splashView)
        splashView.cancelButton.addTarget(self, action: #selector(shouldClose), for: .touchUpInside)

        // If the request is invalid, the controller should be dismissed
		guard let urlRequest = VirtusizeAPI.fitIllustratorURL(jsonResult: jsonResult) else {
            reportError(error: .invalidRequest)
			return
		}
		webView.load(urlRequest)
	}

	// MARK: Rotation Lock
	public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}

    // MARK: Error Handling
    public func reportError(error:CheckTheFitError) {
        delegate?.checkTheFitViewController(self, didReceiveError: CheckTheFitError.invalidRequest)
    }

    // MARK: Closing view
    @objc internal func shouldClose() {
        delegate?.checkTheFitViewControllerShouldClose(self)
    }
}

extension CheckTheFitViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.checkTheFitViewController(self, didReceiveError: CheckTheFitError.navigationError(error))
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.checkTheFitViewController(self, didReceiveError: CheckTheFitError.navigationError(error))
    }
}

extension CheckTheFitViewController: WKScriptMessageHandler {
    // MARK: Widget Callbacks
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "eventHandler" else {
            return
        }
        let event: [String: Any]

        if let eventData = message.body as? [String: Any] {
            event = eventData
        } else if let data = message.body as? Data,
            let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
            let eventData = deserialized as? [String: Any] {
            event = eventData
        } else if let string = message.body as? String {
            guard let data = string.data(using: .utf8) else {
                reportError(error: .encodingError)
                return
            }
            if let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
                let eventData = deserialized as? [String: Any] {
                event = eventData
            } else {
                reportError(error: .deserializationError)
                return
            }
        } else {
            reportError(error: .deserializationError)
            return
        }

        guard let eventName: String = event["name"] as? String else {
            reportError(error: .invalidPayload)
            return
        }

        if eventName == "user-closed-widget" {
            shouldClose()
        }

        if !splashView.isHidden,
            eventName == "user-selected-size" || eventName == "user-opened-panel-start" {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.splashView.alpha = 0
                }, completion: { [weak self] _ in
                self?.splashView.isHidden = true
            })
        }

        let eventData: Any? = event["data"]

        delegate?.checkTheFitViewController(self, didReceiveEvent: eventName, data: eventData)
    }
}
