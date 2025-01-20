//
//  VirtusizeAuth.swift
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

import UIKit
import WebKit
import SafariServices
import VirtusizeCore

public class VirtusizeAuthorization {
	private struct Constants {
		static let nativeAppIdKey = "app_id"
		static let queryRedirectUriKey = "redirect_uri"
		static let authPath = "sns-auth"
	}

	public static let shared = VirtusizeAuthorization()

	private var safariVewController: VirtusizeSafariViewController?

	public class func isSNSAuthURL(
		viewController: UIViewController,
		webView: WKWebView?,
		url: URL
	) -> Bool {
		return VirtusizeAuthorization.shared.isSNSAuthURL(
			viewController: viewController,
			webView: webView,
			url: url
		)
	}

	/// Try to handle an URL as Virtusize SNS callback
	///
	/// - Parameters:
	///   - url: The callback URL
	///
	/// - Returns: true if the URL is successfully handled as Virtusize SNS callback, otherwise false
	public func handleUrl(_ url: URL) -> Bool {
		VirtusizeLogger.debug("handleUrl: \(url)")

		guard let components = URLComponents(string: url.absoluteString),
			  components.scheme?.hasSuffix("virtusize") == true,
			  components.host == Constants.authPath
		else {
			// not a Virtusize URL
			VirtusizeLogger.debug("Not a virtusize URL")
			return false
		}

		guard let safariVC = safariVewController else {
			// Auth Screen already closed
			VirtusizeLogger.debug("Auth ViewController is not visible")
			return false
		}

		// process URL
		return safariVC.handleUrl(url)
	}

	/// Returns true if the url is a redirect url from the SNS auth flow.
	///
	/// - Parameters:
	///   - viewController: The view controller to start the authorization process.
	///   - webView: The web view to handle the auth result.
	///   - url: The authorization url.
	private func isSNSAuthURL(
		viewController: UIViewController,
		webView: WKWebView?,
		url: URL
	) -> Bool {
		guard VirtusizeURLCheck.isSnsLink(url: url, trustedSnsHosts: SnsHost.trustedHosts) else {
			return false
		}

		var authUrlString = url.absoluteString
		authUrlString = authUrlString.removingPercentEncoding ?? authUrlString
		let originalRedirectUri = substringBetweenDelimiters(
			str: authUrlString,
			// start with `&` delimiter to ensure `fallback_redirect_uri` is not detect instead
			after: "&\(Constants.queryRedirectUriKey)=",
			before: "&",
			default: ""
		)
		let region = substringBetweenDelimiters(
			str: originalRedirectUri,
			after: "virtusize.",
			before: "/",
			default: "com"
		)
		let env = substringBetweenDelimiters(
			str: originalRedirectUri,
			after: "sns-proxy/",
			before: "/",
			default: "staging"
		)

		if !originalRedirectUri.isEmpty {
			authUrlString = authUrlString.replacingOccurrences(
				of: originalRedirectUri,
				with: VirtusizeAuthStringHelper.getRedirectUrl(region: region, env: env)
			)
		}

		// HACK `channel_url` breaks the Facebook OAuth, it seems obsolete, so we remove it from the URL
		authUrlString = VirtusizeAuthStringHelper.removeParamFromUrl(
			url: authUrlString,
			paramName: "channel_url"
		)

		authUrlString = updateUrlWithAppBundleId(urlString: authUrlString)
		authUrlString = updateUrlWithSnsType(urlString: authUrlString)
		authUrlString = updateUrlWithEnvironment(urlString: authUrlString, region: region, env: env)

		VirtusizeLogger.debug("AuthUrl: \(authUrlString)")

		if let authURL = URL(string: authUrlString) {
			let virtusizeSVC = VirtusizeSafariViewController(webView: webView, url: authURL, onClose: { [weak self] in
				// reset reference to the controller
				self?.safariVewController = nil
			})
			safariVewController = virtusizeSVC
			viewController.present(virtusizeSVC, animated: true)
			return true
		}

		return false
	}

	/// Updates the auth url with the environment params appended to the state query parameter.
	/// Those parameters are important to restore redirectUri when returned to the app by callback.
	internal func updateUrlWithEnvironment(
		urlString: String,
		region: String,
		env: String
	) -> String {

		let url = updateUrlStateWithProperty(
			urlString: urlString,
			key: VirtusizeAuthConstants.regionKey,
			value: region)

		return updateUrlStateWithProperty(
			urlString: url,
			key: VirtusizeAuthConstants.envKey,
			value: env)
	}

	/// Updates the auth url with the app bundle id appended to the state query parameter.
	private func updateUrlWithAppBundleId(
		urlString: String
	) -> String {
		guard let bundleId = Bundle.main.bundleIdentifier else {
			return urlString
		}

		return updateUrlStateWithProperty(
			urlString: urlString,
			key: Constants.nativeAppIdKey,
			value: bundleId)
	}

	/// Updates the auth url with the app bundle id appended to the state query parameter.
	internal func updateUrlWithSnsType(
		urlString: String
	) -> String {
		guard let snsType = SNSType.from(url: urlString) else {
			VirtusizeLogger.error("Failed to resolve SNS Type from known host.")
			return urlString
		}

		return updateUrlStateWithProperty(
			urlString: urlString,
			key: VirtusizeAuthConstants.snsTypeKey,
			value: snsType.rawValue)
	}

	internal func updateUrlStateWithProperty(
		urlString: String,
		key: String,
		value: String
	) -> String {

		let urlComponents = URLComponents(string: urlString)
		let stateQueryString = urlComponents?.queryItems?
			.first { $0.name == VirtusizeAuthConstants.queryStateKey }?
			.value

		// convert `plain` state value into JSON, to be able extending it with other parameters
		var state = stateQueryString
		if let stateQueryString = stateQueryString,
				!stateQueryString.isEmpty,
				!stateQueryString.contains("{") {
			state = "{\"state\":\"\(state!)\"}"
		}

		let updatedState = VirtusizeAuthStringHelper.appendJsonFieldTo(
			jsonString: state ?? "{}",
			key: key,
			value: value
		)

		return VirtusizeAuthStringHelper.updateQueryParameterTo(
			urlString: urlString,
			name: VirtusizeAuthConstants.queryStateKey,
			value: updatedState
		)
	}

	/// Returns the substring between two delimiters.
	///
	/// - Parameters:
	///  - str: The string to search.
	///  - after: The delimiter to search after.
	///  - before: The delimiter to search before.
	///  - default: The default value to return if the substring is not found.
	private func substringBetweenDelimiters(
		str: String,
		after: String,
		before: String,
		default: String
	) -> String {
		if let lowerRange = str.range(of: after) {
			let subStr = String(str[lowerRange.upperBound...])
			if let upperRange = subStr.range(of: before) {
				return String(subStr[..<upperRange.lowerBound])
			}
		}
		return `default`
	}
}
