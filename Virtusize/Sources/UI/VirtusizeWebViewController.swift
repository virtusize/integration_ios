//
//  VirtusizeWebViewController.swift
//
//  Copyright (c) 2018-present Virtusize KK
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
import VirtusizeCore
import VirtusizeAuth

/// The methods of this protocol notify you with Virtusize specific messages such as errors as
/// `VirtusizeError` and events as `VirtusizeEvent`
public protocol VirtusizeMessageHandler: AnyObject {
	func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveError error: VirtusizeError)
	func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveEvent event: VirtusizeEvent)
}

/// This `UIViewController` represents the Virtusize Window
public final class VirtusizeWebViewController: UIViewController {
	private var product: VirtusizeProduct?
	private var userSessionResponse: String = ""

	public weak var messageHandler: VirtusizeMessageHandler?
	internal weak var eventHandler: VirtusizeEventHandler?

	private var webView: WKWebView?
	private var popupWebView: WKWebView?

	// Allow process pool passing to share cookies
	private var processPool: WKProcessPool?
	
	// Close button and timer properties
	private var closeButton: UIButton?
	private var closeButtonTimer: Timer?

	private static let cookieBidKey = "virtusize.bid"

	public convenience init?(
		product: VirtusizeProduct? = nil,
		messageHandler: VirtusizeMessageHandler? = nil,
		eventHandler: VirtusizeEventHandler? = nil,
		processPool: WKProcessPool? = nil
	) {
		self.init(nibName: nil, bundle: nil)
		self.modalPresentationStyle = .fullScreen
		self.product = product
		self.messageHandler = messageHandler
		self.eventHandler = eventHandler
        self.processPool = processPool
        self.userSessionResponse = VirtusizeRepository.shared.userSessionResponse

//		guard product?.productCheckData != nil else {
//			reportError(error: .invalidProduct)
//			return nil
//		}
	}

    deinit {
        // Debug: temporary observer log to confirm deinit calls
        print("VirtusizeWebViewController: deinit called")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let contentController = WKUserContentController()
        contentController.add(self, name: "eventHandler")

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.userContentController = contentController

        if let processPool = self.processPool {
            config.processPool = processPool
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        // Required for Google SDK to work in WebView, see https://stackoverflow.com/a/73152331
        webView.customUserAgent = VirtusizeAuthConstants.userAgent
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

		loadUrl()
	}

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupCloseButton()
    }

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// Clean up timer when view disappears
        deinitListeners()
		stopCloseButtonTimer()
	}

	@MainActor
	private func loadUrl() {
		Task {
			// If the request is invalid, the controller should be dismissed
			guard let request = await getWebViewURL() else {
				reportError(error: .invalidRequest)
				return
			}
			webView?.load(request)
		}
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
		messageHandler?.virtusizeController(self, didReceiveError: error)
		dismiss(animated: true, completion: nil)
	}

	// MARK: Closing view
	@objc internal func shouldClose() {
		stopCloseButtonTimer()
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Close Button Setup
	private func setupCloseButton() {
		// Create close button
		closeButton = UIButton(type: .system)
		
		// Use SF Symbol xmark if available (iOS 13+), otherwise fallback to custom X
		if #available(iOS 13.0, *) {
			let xmarkImage = UIImage(systemName: "xmark")?
				.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
			closeButton?.setImage(xmarkImage, for: .normal)
		} else {
			// Fallback for older iOS versions
			closeButton?.setTitle("✕", for: .normal)
			closeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		}
		
		closeButton?.tintColor = .black
		closeButton?.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		closeButton?.layer.cornerRadius = 20
		closeButton?.layer.shadowColor = UIColor.black.cgColor
		closeButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
		closeButton?.layer.shadowOpacity = 0.1
		closeButton?.layer.shadowRadius = 4
		closeButton?.addTarget(self, action: #selector(shouldClose), for: .touchUpInside)
		closeButton?.isHidden = true
		
		guard let closeButton = closeButton else { return }
		
		view.addSubview(closeButton)
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		
		// Position button in top right corner
		if #available(iOS 11.0, *) {
			NSLayoutConstraint.activate([
				closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
				closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
				closeButton.widthAnchor.constraint(equalToConstant: 40),
				closeButton.heightAnchor.constraint(equalToConstant: 40)
			])
		} else {
			NSLayoutConstraint.activate([
				closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
				closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
				closeButton.widthAnchor.constraint(equalToConstant: 40),
				closeButton.heightAnchor.constraint(equalToConstant: 40)
			])
		}
		
		// Start timer to show button after 6 seconds
		startCloseButtonTimer()
	}
	
	private func startCloseButtonTimer() {
		closeButtonTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { [weak self] _ in
			DispatchQueue.main.async {
				self?.showCloseButton()
			}
		}
	}
	
	private func stopCloseButtonTimer() {
		closeButtonTimer?.invalidate()
		closeButtonTimer = nil
	}

    private func deinitListeners() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "eventHandler")
    }

	private func showCloseButton() {
		UIView.animate(withDuration: 0.3, animations: {
			self.closeButton?.isHidden = false
			self.closeButton?.alpha = 1.0
		})
	}
	
	private func hideCloseButton() {
		UIView.animate(withDuration: 0.3, animations: {
			self.closeButton?.alpha = 0.0
		}) { _ in
			self.closeButton?.isHidden = true
		}
	}

    private func getWebViewURL() async -> URLRequest? {
        if let productStoreId = product?.productCheckData?.storeId, StoreId(value: productStoreId).isUnitedArrows {
            return APIRequest.virtusizeWebViewForSpecificClients()
        } else {
            guard let version = await VirtusizeAPIService.fetchLatestAoyamaVersion().success else {
                return nil
            }
            return APIRequest.virtusizeWebView(version: version)
        }
    }
}

extension VirtusizeWebViewController: WKNavigationDelegate, WKUIDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		guard let vsParamsFromSDKScript = Virtusize.params?.getVsParamsFromSDKScript(
			externalProductId: product?.externalId,
			userSessionResponse: userSessionResponse
		) else {
			reportError(error: .invalidVsParamScript)
			return
		}

        // HotFix: temporary fix log to solve webview race condition related to vsParamsFromSDK
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in

            webView.evaluateJavaScript(vsParamsFromSDKScript) { response, error in
                if let error = error {
                    // Debug: temporary observer log to detect JS exception
                    print("Evaluate JavaScript exception: \(error.localizedDescription)")
                }
            }

            if let showSNSButtons = Virtusize.params?.showSNSButtons {
                webView.evaluateJavaScript("window.virtusizeSNSEnabled = \(showSNSButtons);") { response, error in
                    if let error = error {
                        // Debug: temporary observer log to detect JS exception
                        print("Evaluate JavaScript exception: \(error.localizedDescription)")
                    }
                }
            }

            self?.checkAndUpdateBrowserID()
        }
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

		if VirtusizeAuthorization.isSNSAuthURL(viewController: self, webView: webView, url: url) {
			return nil
		}

		guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
			// By default, The Google sign-in page shows a 403 error: disallowed_useragent
			//   if you are visiting it within a Webview.
			// By setting up the user agent, Google recognizes the web view as a Safari browser
			configuration.applicationNameForUserAgent = "CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"
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
							cookieValue != UserDefaultsHelper.current.identifier {
							UserDefaultsHelper.current.identifier = cookie.value
						}
					}
				}
			})
		} else {
			if let cookies = HTTPCookieStorage.shared.cookies {
				for cookie in cookies
				where cookie.name == VirtusizeWebViewController.cookieBidKey &&
					cookie.value != UserDefaultsHelper.current.identifier {
					UserDefaultsHelper.current.identifier = cookie.value
				}
			}
		}
	}
}

extension VirtusizeWebViewController: WKScriptMessageHandler {
	// MARK: - Widget Callbacks
	// swiftlint:disable:next cyclomatic_complexity
	public func userContentController(
		_ userContentController: WKUserContentController,
		didReceive message: WKScriptMessage) {
		guard message.name == "eventHandler" else {
			return
		}
		do {
			let event = try Deserializer.event(data: message.body)
			let eventData = event.data as? [String: Any]
			let eventName = VirtusizeEventName.init(rawValue: event.name)
			switch eventName {
			case .userOpenedWidget:
				eventHandler?.userOpenedWidget()
			case .userAuthData:
				eventHandler?.userAuthData(
					bid: eventData?["x-vs-bid"] as? String,
					auth: eventData?["x-vs-auth"] as? String
				)
			case .userSelectedProduct:
				eventHandler?.userSelectedProduct(userProductId: (event.data as? [String: Any])?["userProductId"] as? Int)
			case .userAddedProduct:
				eventHandler?.userAddedProduct()
			case .userDeletedProduct:
				eventHandler?.userDeletedProduct(userProductId: eventData?["userProductId"] as? Int)
			case .userChangedRecommendationType:
				let recommendationType = eventData?["recommendationType"] as? String
				let changedType = (recommendationType != nil) ? SizeRecommendationType.init(rawValue: recommendationType!) : nil
				eventHandler?.userChangedRecommendationType(changedType: changedType)
			case .userUpdatedBodyMeasurements:
				let sizeRecName = eventData?["sizeRecName"] as? String
				eventHandler?.userUpdatedBodyMeasurements(recommendedSize: sizeRecName)
			case .userLoggedIn:
				eventHandler?.userLoggedIn()
			case .userLoggedOut, .userDeletedData:
				eventHandler?.clearUserData()
			case .userClosedWidget:
				eventHandler?.userClosedWidget()
				shouldClose()
			case .userClickedLanguageSelector:
				let language = eventData?["language"] as? String
                if let language = language{
                    if let validLanguage = VirtusizeLanguage(rawValue: language) {
                        eventHandler?.userClickedLanguageSelector(language: validLanguage)
                    }
                }
            case .widgetReady:
				// Stop the close button timer and hide the button when widget is ready
				stopCloseButtonTimer()
				hideCloseButton()
			default:
				break
			}
			messageHandler?.virtusizeController(self, didReceiveEvent: event)
		} catch {
			if let error = error as? VirtusizeError {
				reportError(error: error)
			}
		}
	}
}
