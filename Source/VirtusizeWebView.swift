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

	open override var navigationDelegate: WKNavigationDelegate? {
		didSet {
			guard navigationDelegate?.isEqual(self) == false else {
				return
			}

			wkNavigationDelegate = navigationDelegate
			navigationDelegate = self
		}
	}

	private weak var wkNavigationDelegate: WKNavigationDelegate?

	public init(frame: CGRect, configurationClosure: ((WKWebViewConfiguration) -> Void)? = nil) {
		let configuration = WKWebViewConfiguration()
		configuration.processPool = VSProcessPool.pool
		configurationClosure?(configuration)
		super.init(frame: frame, configuration: configuration)
		uiDelegate = self
		navigationDelegate = self
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		uiDelegate = self
		navigationDelegate = self
	}
}

extension VirtusizeWebView: WKUIDelegate {
	public func webView(
		_ webView: WKWebView,
		createWebViewWith configuration: WKWebViewConfiguration,
		for navigationAction: WKNavigationAction,
		windowFeatures: WKWindowFeatures
	) -> WKWebView? {
		guard let url = navigationAction.request.url else {
			return nil
		}

		if isExternalLinkFromVirtusize(url: url.absoluteString) {
			if let sharedApplication = UIApplication.safeShared {
				sharedApplication.safeOpenURL(url)
				return nil
			}
		}

		if navigationAction.targetFrame == nil && isLinkFromSNSAuth(url: url.absoluteString) {
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

	public func webViewDidClose(_ webView: WKWebView) {
		webView.removeFromSuperview()
		wkUIDelegate?.webViewDidClose?(webView)
	}

	public func webView(
		_ webView: WKWebView,
		runJavaScriptAlertPanelWithMessage message: String,
		initiatedByFrame frame: WKFrameInfo,
		completionHandler: @escaping () -> Void
	) {
		if wkUIDelegate?.webView?(
			webView,
			runJavaScriptAlertPanelWithMessage: message,
			initiatedByFrame: frame,
			completionHandler: completionHandler
		) == nil {
			completionHandler()
		}
	}

	public func webView(
		_ webView: WKWebView,
		runJavaScriptConfirmPanelWithMessage message: String,
		initiatedByFrame frame: WKFrameInfo,
		completionHandler: @escaping (Bool) -> Void
	) {
		if wkUIDelegate?.webView?(
			webView,
			runJavaScriptConfirmPanelWithMessage: message,
			initiatedByFrame: frame,
			completionHandler: completionHandler
		) == nil {
			completionHandler(false)
		}
	}

	public func webView(
		_ webView: WKWebView,
		runJavaScriptTextInputPanelWithPrompt prompt: String,
		defaultText: String?,
		initiatedByFrame frame: WKFrameInfo,
		completionHandler: @escaping (String?) -> Void
	) {
		if wkUIDelegate?.webView?(
			webView,
			runJavaScriptTextInputPanelWithPrompt: prompt,
			defaultText: defaultText,
			initiatedByFrame: frame,
			completionHandler: completionHandler
		) == nil {
			completionHandler(nil)
		}
	}

	public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
		wkUIDelegate?.webView?(webView, shouldPreviewElement: elementInfo) ?? false
	}

	public func webView(
		_ webView: WKWebView,
		previewingViewControllerForElement elementInfo: WKPreviewElementInfo,
		defaultActions previewActions: [WKPreviewActionItem]
	) -> UIViewController? {
		return wkUIDelegate?.webView?(
			webView,
			previewingViewControllerForElement: elementInfo,
			defaultActions: previewActions
		)
	}

	public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
		wkUIDelegate?.webView?(webView, commitPreviewingViewController: previewingViewController)
	}

	@available(iOS 13.0, *)
	public func webView(
		_ webView: WKWebView,
		contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo,
		completionHandler: @escaping (UIContextMenuConfiguration?) -> Void
	) {
		if wkUIDelegate?.webView?(
			webView,
			contextMenuConfigurationForElement: elementInfo,
			completionHandler: completionHandler
		) == nil {
			completionHandler(nil)
		}
	}

	@available(iOS 13.0, *)
	public func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
		wkUIDelegate?.webView?(webView, contextMenuWillPresentForElement: elementInfo)
	}

	@available(iOS 13.0, *)
	public func webView(
		_ webView: WKWebView,
		contextMenuForElement elementInfo: WKContextMenuElementInfo,
		willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating
	) {
		wkUIDelegate?.webView?(webView, contextMenuForElement: elementInfo, willCommitWithAnimator: animator)
	}

	@available(iOS 13.0, *)
	public func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
		wkUIDelegate?.webView?(webView, contextMenuDidEndForElement: elementInfo)
	}

	/// Checks if a URL is an external link from Virtusize to be open on the Safari browser
	private func isExternalLinkFromVirtusize(url: String?) -> Bool {
		return url != nil && (url!.contains("surveymonkey") || (url!.contains("virtusize") && url!.contains("privacy")))
	}

	/// Checks if a URL is a link from SNS authentication
	private func isLinkFromSNSAuth(url: String?) -> Bool {
		return url != nil && (url!.contains("facebook") || url!.contains("google")) && url!.contains("oauth")
	}
}

extension VirtusizeWebView: WKNavigationDelegate {

	public func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void
	) {
		if let url = webView.url, isExternalLinkFromVirtusize(url: url.absoluteString) {
			if let sharedApplication = UIApplication.safeShared {
				decisionHandler(.cancel)
				sharedApplication.safeOpenURL(url)
				return
			}
		}

		if wkNavigationDelegate?.webView?(
			webView,
			decidePolicyFor: navigationAction,
			decisionHandler: decisionHandler
		) == nil {
			decisionHandler(.allow)
		}
	}

	@available(iOS 13.0, *)
	public func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		preferences: WKWebpagePreferences,
		decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
	) {
		if wkNavigationDelegate?.webView?(
			webView,
			decidePolicyFor: navigationAction,
			preferences: preferences,
			decisionHandler: decisionHandler
		) == nil {
			self.webView(webView, decidePolicyFor: navigationAction) { (policy) in
				decisionHandler(policy, preferences)
			}
		}
	}

	public func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationResponse: WKNavigationResponse,
		decisionHandler: @escaping (WKNavigationResponsePolicy
		) ->
							Swift.Void) {
		if wkNavigationDelegate?.webView?(
			webView,
			decidePolicyFor: navigationResponse,
			decisionHandler: decisionHandler
		) == nil {
			decisionHandler(.allow)
		}
	}

	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		wkNavigationDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
	}

	public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		wkNavigationDelegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
	}

	public func webView(
		_ webView: WKWebView,
		didFailProvisionalNavigation navigation: WKNavigation!,
		withError error: Error
	) {
		wkNavigationDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
	}

	public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		wkNavigationDelegate?.webView?(webView, didCommit: navigation)
	}

	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		evaluateJavaScript("window.virtusizeSNSEnabled = true;", completionHandler: nil)
		wkNavigationDelegate?.webView?(webView, didFinish: navigation)
	}

	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		wkNavigationDelegate?.webView?(webView, didFail: navigation, withError: error)
	}

	public func webView(
		_ webView: WKWebView,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void
	) {
		guard wkNavigationDelegate?.webView?(
				webView,
				didReceive: challenge,
				completionHandler: completionHandler
		) != nil else {
			completionHandler(.rejectProtectionSpace, nil)
			return
		}
	}

	public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
		wkNavigationDelegate?.webViewWebContentProcessDidTerminate?(webView)
	}

	@available(iOS 14.0, *)
	public func webView(
		_ webView: WKWebView,
		authenticationChallenge challenge: URLAuthenticationChallenge,
		shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void
	) {
		if wkNavigationDelegate?.webView?(
			webView,
			authenticationChallenge: challenge,
			shouldAllowDeprecatedTLS: decisionHandler
		) == nil {
			decisionHandler(false)
			return
		}
	}

	@available(iOS 14.5, *)
	public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
		wkNavigationDelegate?.webView?(webView, navigationAction: navigationAction, didBecome: download)
	}

	@available(iOS 14.5, *)
	public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
		wkNavigationDelegate?.webView?(webView, navigationResponse: navigationResponse, didBecome: download)
	}
}
