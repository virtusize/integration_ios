//
//  VirtusizeAPIService.swift
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

/// This class is to handle API requests to the Virtusize server
open class APIService {

	/// A default session configuration object for a URL session.
	private static let sessionConfiguration = URLSessionConfiguration.default

	/// A session that confirms to `APISessionProtocol` for mocking API responses in testing
	internal static var session: APISessionProtocol = URLSession(
		configuration: sessionConfiguration,
		delegate: nil,
		delegateQueue: nil
	)

	/// Performs an API request asynchronously
	///
	/// - Parameter request: A URL load request for an API request
	/// - Returns the `APIResponse`
	public static func performAsync(_ request: URLRequest) async -> APIResponse {
		do {
			let (data, response) = try await APIService.session.data(for: request)

			var virtusizeError: VirtusizeError?
			if let httpResponse = response as? HTTPURLResponse, !httpResponse.isSuccessful() {
				let errorDescription =
					if let asUtf8 = String(data: data, encoding: .utf8) {
						asUtf8
					} else {
						VirtusizeError.unknownError.debugDescription
					}
				virtusizeError = VirtusizeError.apiRequestError(request.url, errorDescription)
			}

			return APIResponse(
				code: (response as? HTTPURLResponse)?.statusCode ?? nil,
				data: data,
				response: response,
				virtusizeError: virtusizeError
			)
		} catch {
			return APIResponse(
				error: error,
				virtusizeError: VirtusizeError.apiRequestError(
					request.url,
					error.localizedDescription
				)
			)
		}
	}

	/// Gets the result of an asynchronous API request
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - type: The API result data in the generic type
	public static func getAPIResultAsync<T: Decodable>(request: URLRequest, type: T.Type?) async -> APIResult<T> {
		let apiResponse = await performAsync(request)
		guard apiResponse.virtusizeError == nil,
			  let data = apiResponse.data else {
			return .failure(apiResponse.code, apiResponse.virtusizeError)
		}

		if type == nil || data.count == 0 {
			return .success()
		}

		do {
			let result = try JSONDecoder().decode(type!, from: data)
			let jsonString = String(data: data, encoding: String.Encoding.utf8)
			return .success(result, jsonString)
		} catch {
			return .failure(apiResponse.code, VirtusizeError.jsonDecodingFailed(String(describing: type), error))
		}
	}
}
