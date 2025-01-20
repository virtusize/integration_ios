//
//  JsonHelper.swift
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

import Testing
import Foundation

func expectJsonMatch(_ current: String, _ expected: String) {
	let data1 = current.data(using: .utf8)!
	let data2 = expected.data(using: .utf8)!
	do {
		if let currentJson = try JSONSerialization.jsonObject(with: data1, options: []) as? [String: Any],
		   let expectedJson = try JSONSerialization.jsonObject(with: data2, options: []) as? [String: Any] {
			#expect(currentJson as NSDictionary == expectedJson as NSDictionary)
		} else {
			Issue.record("Filed to convert string to JSON.")
		}
	} catch {
		Issue.record("Error while converting string to JSON.")
	}
}

func expectUrlWithJsonParamMatch(_ current: String?, _ expected: String, paramName: String) {
	guard let current = current else {
		Issue.record("Current URL is nil.")
		return
	}

	let items1 = URLComponents(string: current)?.queryItems ?? []
	let items2 = URLComponents(string: expected)?.queryItems ?? []

	let json1 = items1.first(where: { $0.name == paramName })?.value
	let json2 = items2.first(where: { $0.name == paramName })?.value

	guard let current = json1, let expected = json2 else {
		#expect(current == expected)
		return
	}

	expectJsonMatch(current, expected)
}
