//
//  APISessionProtocol.swift
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

import Foundation

/// `URLSession` is extended to conform to `APISessionProtocol`
extension URLSession: APISessionProtocol {
}

/// A protocol type for sessions, implemented by `URLSession`
protocol APISessionProtocol {

	/// Uses requests of type `URLRequest` to produce responses of type `Data` and errors of type `Error`for dataTask
	///
	/// - Parameters:
	///   - with: A `URLRequest`
	///   - completionHandler: The completion callback to pass responses of type `Data` and errors of type `Error`
	///
	/// - Returns: `URLSessionDataTask`
	func dataTask(
		with request: URLRequest,
		completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void)
	-> URLSessionDataTask
}

extension APISessionProtocol {
	/// Convenience method to load data using a URLRequest, creates and resumes a URLSessionDataTask internally.
	///
	/// - Parameter request: The URLRequest for which to load data.
	/// - Returns: Data and response.
	public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		return try await withCheckedThrowingContinuation { continuation in
			let task = dataTask(with: request, completionHandler: { data, response, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: (data!, response!))
				}
			})
			task.resume()
		}
	}
}
