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

	/// A closure that is called when the operation completes
	public typealias CompletionHandler = (Data?) -> Void

	/// A closure that is called when the operation fails
	public typealias ErrorHandler = (VirtusizeError) -> Void

	/// A default session configuration object for a URL session.
	private static let sessionConfiguration = URLSessionConfiguration.default

	/// A session that confirms to `APISessionProtocol` for mocking API responses in testing
	internal static var session: APISessionProtocol = URLSession(
		configuration: sessionConfiguration,
		delegate: nil,
		delegateQueue: nil
	)

	/// Performs an API request.
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - completionHandler: A callback to pass data back when an API request is successful
	///   - error: A callback to pass `VirtusizeError` back when an API request is unsuccessful
	public static func perform(
		_ request: URLRequest,
		completion completionHandler: CompletionHandler? = nil,
		error errorHandler: ErrorHandler? = nil
	) {
		let task: URLSessionDataTask

		task = APIService.session.dataTask(with: request) { (data, response, error) in

			guard error == nil else {
				DispatchQueue.main.async {
					errorHandler?(VirtusizeError.apiRequestError(request.url, error!.localizedDescription))
				}
				return
			}

			if let httpResponse = response as? HTTPURLResponse, !httpResponse.isSuccessful() {
				var errorDebugDescription = VirtusizeError.unknownError.debugDescription
				if let data = data {
					errorDebugDescription = String(decoding: data, as: UTF8.self)
				}
				DispatchQueue.main.async {
					errorHandler?(VirtusizeError.apiRequestError(request.url, errorDebugDescription))
				}
			} else {
				DispatchQueue.main.async {
					completionHandler?(data)
				}
			}
		}
		task.resume()
		URLSession.shared.finishTasksAndInvalidate()
	}

	/// Gets the result of an API request
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - onSuccess: A callback to pass back the data in a generic type when an API request is successful
	///   - onError: A callback to pass `VirtusizeError` back when an API request is unsuccessful
	private static func getAPIResult<T: Decodable>(
		request: URLRequest,
		onSuccess: ((T) -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) {
		perform(request, completion: { data in
			guard let data = data else {
				return
			}
			do {
				let result = try JSONDecoder().decode(T.self, from: data)
				onSuccess?(result)
			} catch {
				onError?(VirtusizeError.jsonDecodingFailed(String(describing: T.self), error))
			}
		}, error: { error in
			onError?(error)
		})
	}

	/// Performs an API request asynchronously
	///
	/// - Parameter request: A URL load request for an API request
	/// - Returns the `APIResponse`
	public static func performAsync(_ request: URLRequest) -> APIResponse? {
		var apiResponse: APIResponse?
		let semaphore = DispatchSemaphore(value: 0)
		let task: URLSessionDataTask
		task = APIService.session.dataTask(with: request) { (data, response, error) in
			apiResponse = APIResponse(
				code: (response as? HTTPURLResponse)?.statusCode ?? nil,
				data: data,
				response: response,
				error: error
			)
			semaphore.signal()
		}
		task.resume()
		URLSession.shared.finishTasksAndInvalidate()

		_ = semaphore.wait(timeout: .distantFuture)

		guard apiResponse != nil else {
			return apiResponse
		}

		guard apiResponse!.error == nil else {
			apiResponse!.virtusizeError = VirtusizeError.apiRequestError(
				request.url,
				apiResponse!.error!.localizedDescription
			)
			return apiResponse
		}

		if let httpResponse = apiResponse!.response as? HTTPURLResponse, !httpResponse.isSuccessful() {
			var errorDebugDescription = VirtusizeError.unknownError.debugDescription
			if let data = apiResponse?.data {
				errorDebugDescription = String(decoding: data, as: UTF8.self)
			}
			apiResponse!.virtusizeError = VirtusizeError.apiRequestError(request.url, errorDebugDescription)
		}
		return apiResponse
	}

	/// Gets the result of an asynchronous API request
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - type: The API result data in the generic type
	public static func getAPIResultAsync<T: Decodable>(request: URLRequest, type: T.Type?) -> APIResult<T> {
		let apiResponse = performAsync(request)
		guard apiResponse?.virtusizeError == nil,
			  let data = apiResponse?.data else {
			return .failure(apiResponse?.code, apiResponse?.virtusizeError)
		}

		if type == nil || data.count == 0 {
			return .success()
		}

		do {
			let result = try JSONDecoder().decode(type!, from: data)
			let jsonString = String(data: data, encoding: String.Encoding.utf8)

			return .success(result, jsonString)

		} catch {
			return .failure(apiResponse?.code, VirtusizeError.jsonDecodingFailed(String(describing: type), error))
		}
	}
}
