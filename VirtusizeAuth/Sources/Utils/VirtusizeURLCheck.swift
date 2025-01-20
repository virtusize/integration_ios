//
//  VirtusizeURLCheck.swift
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

import Foundation

public class VirtusizeURLCheck {

	/// Checks if a URL is an external link from Virtusize to be open on the Safari browser
	public static func isExternalLinkFromVirtusize(url: String?) -> Bool {
		return url != nil && (url!.contains("surveymonkey") || (url!.contains("virtusize") && url!.contains("privacy")))
	}

	/// Checks if a URL is a link from Virtusize SNS authentication
	public static func isLinkFromSNSAuth(url: String?) -> Bool {
        return url != nil && url!.contains("virtusize") && url!.contains("auth")
	}

    /// Checks if a URL is a link from Virtusize Fit Illustrator
    public static func isFitIllustratorLink(url: String?) -> Bool {
        return url != nil && url!.contains("virtusize") && url!.contains("fit-illustrator")
    }

	/// Checks if an URL is an app specific SNS Callback
	public static func isSnsCallback(url: URL) -> Bool {
		guard let components = URLComponents(string: url.absoluteString),
			  components.scheme?.hasSuffix("virtusize") == true,
			  components.host == "sns-auth"
		else {
			return false
		}
		return true
	}

	public static func isSnsLink(url: URL, trustedSnsHosts: [String]) -> Bool {
		let isKnownHost = trustedSnsHosts.contains { host in
			if #available(iOS 16.0, *) {
				url.host()?.contains(host) ?? false
			} else {
				url.host?.contains(host) ?? false
			}
		}

		let isOAuthPath =
			if #available(iOS 16.0, *) {
				url.path().contains("oauth")
			} else {
				url.path.contains("oauth")
			}

		let isVirtusizeSpecific =
			if #available(iOS 16.0, *) {
				url.query()?.contains("virtusize") ?? false
			} else {
				url.query?.contains("virtusize") ?? false
			}

		return isKnownHost && isOAuthPath && isVirtusizeSpecific
	}
}
