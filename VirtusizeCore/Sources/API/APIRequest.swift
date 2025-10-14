//
//  APIRequest.swift
//  VirtusizeCore
//
//  Copyright (c) 2021 Virtusize KK
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

public typealias JSONObject = [String: Any]
internal typealias JSONArray = [JSONObject]

/// This enum contains supported HTTP request methods
public enum APIMethod: String {
	case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

/// A structure to get `URLRequest`s for Virtusize API requests
public struct APIRequest {
	/// Gets a `URLRequest` for a HTTP request
	///
	/// - Parameters:
	///   - components: `URLComponents` to obtain the `URL`
	///   - method: An `APIMethod` that defaults to the `GET` HTTP method
	/// - Returns: A `URLRequest` for this HTTP request
	public static func HTTPRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
		guard let url = components.url else {
			fatalError("Endpoint URL components creation failed")
		}

		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		return request
	}

	/// Gets the `URLRequest` for the HTTP request where the Browser Identifier is added
	///
	/// - Parameters:
	///   - components: `URLComponents` to obtain the `URL`
	///   - method: An `APIMethod` that defaults to the `GET` HTTP method
	/// - Returns: A `URLRequest` for this HTTP request
	public static func apiRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
		var request = HTTPRequest(components: components, method: method)
		request.addValue(UserDefaultsHelper.current.identifier, forHTTPHeaderField: "x-vs-bid")
        if let storeId = APICache.shared.currentStoreId {
            request.addValue(String(storeId), forHTTPHeaderField: "x-vs-store-id")
        }
        if let userId = APICache.shared.currentUserId,
           let authToken = UserDefaultsHelper.current.authToken, !authToken.isEmpty {
            request.addValue(userId, forHTTPHeaderField: "x-vs-external-user-id")
        }
		return request
	}

	/// Gets the `URLRequest` for the HTTP request that gets user sessions
	///
	/// - Parameters:
	///   - components: `URLComponents` to obtain the `URL`
	/// - Returns: A `URLRequest` for this HTTP request
	public static func apiRequestWithAuthHeader(components: URLComponents, method: APIMethod = .post) -> URLRequest {
		var request = apiRequest(components: components, method: method)
		request.addValue(UserDefaultsHelper.current.authToken ?? "", forHTTPHeaderField: "x-vs-auth")
		request.addValue("", forHTTPHeaderField: "Cookie")
		return request
	}

    /// Gets the `URLRequest` for the HTTP request that gets user sessions
    ///
    /// - Parameters:
    ///   - components: `URLComponents` to obtain the `URL`
    /// - Returns: A `URLRequest` for this HTTP request
    public static func apiRequestWithAuthHeader(
        components: URLComponents,
        withPayload payload: Data,
        method: APIMethod = .post
    ) -> URLRequest {
        var request = apiRequest(components: components, method: method)
        request.addValue(UserDefaultsHelper.current.authToken ?? "", forHTTPHeaderField: "x-vs-auth")
        request.addValue("", forHTTPHeaderField: "Cookie")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        return request
    }

	/// Gets the `URLRequest` for the HTTP request that requires authentication
	///
	/// - Parameters:
	///   - components: `URLComponents` to obtain the `URL`
	///   - method: An `APIMethod` that defaults to the `GET` HTTP method
	/// - Returns: A `URLRequest` for this HTTP request
	public static func apiRequestWithAuthorization(components: URLComponents, method: APIMethod = .get) -> URLRequest {
		var request = apiRequest(components: components, method: method)
		guard let accessToken = UserDefaultsHelper.current.accessToken else {
			return request
		}
		request.addValue("Token \(accessToken)", forHTTPHeaderField: "Authorization")
		return request
	}
    /// Gets the `URLRequest` for the HTTP request where the request body is added
    ///
    /// - Parameters:
    ///   - components: `URLComponents` to obtain the `URL`
    ///   - payload: A `Data` that is sent as the message body of the request
    /// - Returns: A `URLRequest` for this HTTP request
    public static func apiRequest(
        components: URLComponents,
        withPayload payload: Data,
        method: APIMethod = .post
    ) -> URLRequest {
        var request = apiRequest(components: components, method: method)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        return request
    }
}
