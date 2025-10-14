//
//  VirtusizeSafariViewController.swift
//  VirtusizeAuth
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
import SafariServices
import VirtusizeCore

final class VirtusizeSafariViewController: SFSafariViewController {

	private let webView: WKWebView?
	private let onClose: (() -> Void)?

	required init(webView: WKWebView?, url URL: URL, onClose: @escaping () -> Void) {
		self.webView = webView
		self.onClose = onClose

		super.init(url: URL, configuration: SFSafariViewController.Configuration())

		self.modalPresentationStyle = .overCurrentContext
	}

	/// Process the OAuth URL callback and exchange the OAuth token with Virtusize server
	/// - Returns true if the URL properly processed, otherwise false
    public func handleUrl(_ url: URL) -> Bool { // swiftlint:disable:this function_body_length
        guard let params = URLComponents(string: url.absoluteString)?.queryItems else {
            return false
        }

		// SNS Type (OAuth Provider) is resolved from `state` parameter which is JSON formatted
		var stateSnsType: SNSType?
		var env: String?
		var region: String?

		if let state = params.first(where: { $0.name == VirtusizeAuthConstants.queryStateKey})?.value,
		   let stateDict = VirtusizeAuthStringHelper.getJsonDict(jsonString: state) {
			stateSnsType = (stateDict[VirtusizeAuthConstants.snsTypeKey] as? String).flatMap(SNSType.init)
			env = stateDict[VirtusizeAuthConstants.envKey] as? String
			region = stateDict[VirtusizeAuthConstants.regionKey] as? String
		}

		guard let snsType = stateSnsType else {
			VirtusizeLogger.warn("Failed to detect SNS provider type.")
            return false
        }

        guard
            let accessToken = params.first(where: { $0.name == VirtusizeAuthConstants.snsAccessTokenKey})?.value
				?? params.first(where: { $0.name == VirtusizeAuthConstants.snsCodeKey})?.value
        else {
            // can't find access token
			VirtusizeLogger.warn("no '\(VirtusizeAuthConstants.snsAccessTokenKey)' parameter")
            return false
        }

        var authProvider: VirtusizeAuthProvider?
		switch snsType {
		case .facebook:
			authProvider = FacebookAuthProvider()
		case .google:
			authProvider = GoogleAuthProvider()
		case .line:
			self.webView?.evaluateJavaScript(
				"""
					sdkSnsLogin({
						code: '\(accessToken)',
						snsType: 'line'
					})
				""",
				completionHandler: { _, err in
					// close the SafariViewController
					VirtusizeLogger.debug("Closing SNS SafariViewController with error: \(err?.localizedDescription ?? "nil")")
					self.dismiss(animated: true)
					self.onClose?()
				}
			)
			return true
		}

		Task { @MainActor in
            if let snsUser = await authProvider?.getUserInfo(accessToken: accessToken) {
				// WARNING avoid using async `evaluateJavaScript` yet as there is an Apple bug
				// see https://developer.apple.com/forums/thread/701553
				self.webView?.evaluateJavaScript(
					"""
						receiveSNSParamsFromSDK(
							{
								accessId: '\(snsUser.id)',
								snsType: '\(snsUser.snsType)',
								displayName: '\(snsUser.name)',
								email: '\(snsUser.email)'
							}
						)
					""",
					completionHandler: { _, err in
						// close the SafariViewController
						VirtusizeLogger.debug("Closing SNS SafariViewController with error: \(err?.localizedDescription ?? "nil")")
						self.dismiss(animated: true)
						self.onClose?()
					}
				)
			} else {
				VirtusizeLogger.debug("Failed to resolve a user by access token")
			}
        }

        return true
    }
}
