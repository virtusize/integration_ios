//
//  APIResponse.swift
//
//  Copyright (c) 2020 Virtusize KK
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

// The wrapper for the API response
public struct APIResponse: Sendable {
	/// The API response status code
	public var code: Int?
	/// The API response data
	public var data: Data?
	/// The API response in `URLResponse`
	var response: URLResponse?
	/// The API response error
	var error: Error?
	/// The API response error in the format of `VirtusizeError`
	public var virtusizeError: VirtusizeError?

	init(code: Int?, data: Data?, response: URLResponse?, virtusizeError: VirtusizeError?) {
		self.code = code
		self.data = data
		self.response = response
		self.virtusizeError = virtusizeError
		self.error = nil
	}

	init(error: Error, virtusizeError: VirtusizeError) {
		self.code = nil
		self.data = nil
		self.response = nil
		self.error = error
		self.virtusizeError = virtusizeError
	}
}

public typealias Code = Int

public enum APIResult<Value> {
	case success(Value? = nil, String? = nil)
	case failure(Code? = nil, VirtusizeError? = nil)
}

extension APIResult {
	/// The string of the API result 
	public var string: String? {
		switch self {
		case let .success(_, jsonString):
			return jsonString
		case let .failure(_, error):
			return error?.debugDescription
		}
	}

	/// The API result when the request is successful
	public var success: Value? {
		if case .success(let value, _) = self {
			return value
		} else {
			return nil
		}
	}

	/// The API error status code
	public var errorCode: Int? {
		if case .failure(let code, _) = self {
			return code
		} else {
			return nil
		}
	}

	/// The API result when the request fails
	public var failure: VirtusizeError? {
		if case .failure(_, let error) = self {
			return error
		} else {
			return nil
		}
	}

	public var isSuccessful: Bool {
		return failure == nil
	}
}
