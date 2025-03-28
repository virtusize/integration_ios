//
//  FacebookAPIRequest.swift
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
import VirtusizeCore

extension APIRequest {
	/// Get the request to get the Facebook user data.
	///
	/// - Parameter accessToken: The access token to use for the request.
	/// - Returns: A `URLRequest` object.
	internal static func getFacebookUser(accessToken: String) ->
	URLRequest {
		var urlComponents = URLComponents()
		urlComponents.scheme = "https"
		urlComponents.host = "graph.facebook.com"
		urlComponents.path = "/v2.9/me"
		urlComponents.queryItems = [
			URLQueryItem(
				name: "fields",
				value: "email,first_name,last_name,name,timezone,verified"
			),
			URLQueryItem(
				name: VirtusizeAuthConstants.snsAccessTokenKey,
				value: accessToken
			)
		]
		return apiRequest(components: urlComponents)
	}
}
