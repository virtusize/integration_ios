//
//  MockURLSession.swift
//  Virtusize
//
//  Copyright (c) 2025 Virtusize KK
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

@testable import VirtusizeCore
@testable import Virtusize

typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

class MockURLSession: APISessionProtocol {

	private let dataTask: MockTask?
	private var dataTasks: [String: MockTask] = [:]

	init() {
		dataTask = nil
	}

	init(data: Data?, urlResponse: URLResponse?, error: Error?) {
		dataTask = MockTask(
			data: data,
			urlResponse: urlResponse ?? HTTPURLResponse(
				url: URL(string: "https://virtusize.com")!, statusCode: 200, httpVersion: nil, headerFields: [:]),
			error: error
		)
	}

	func mockResponse(endpoint: APIEndpoints, data: Data?) {
		let path = endpoint.components.path
		dataTasks[path] = MockTask(
			data: data,
			urlResponse: HTTPURLResponse(
				url: URL(string: "https://virtusize.com")!, statusCode: 200, httpVersion: nil, headerFields: [:]),
			error: nil
		)
	}

	func dataTask(
		with request: URLRequest,
		completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
	-> URLSessionDataTask {
		let path = request.url?.path ?? ""
		let dataTask = dataTasks
						.first(where: { path.hasSuffix($0.key) })
						.map({ $0.value })
					?? dataTask

		guard let dataTask = dataTask else {
			fatalError("Failed to find the task by URL")
		}

		dataTask.completionHandler = completionHandler
		return dataTask
	}
}

class MockTask: URLSessionDataTask, @unchecked Sendable {
	private let data: Data?
	private let urlResponse: URLResponse?
	private let responseError: Error?

	var completionHandler: CompletionHandler?

	init(data: Data?, urlResponse: URLResponse?, error: Error?) {
		self.data = data
		self.urlResponse = urlResponse
		self.responseError = error
	}

	override func resume() {
		DispatchQueue.main.async {
			self.completionHandler?(self.data, self.urlResponse, self.responseError)
		}
	}
}
