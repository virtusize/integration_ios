//
//  URL+ExtensionsTest.swift
//  VirtusizeCore
//
//  Copyright (c) 2024 Virtusize KK
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
@testable import VirtusizeCore

struct UrlExtensionsTest {
	@Test func addNew() {
		let url = URL(string: "http://example.com")
		let result = url?.addOrUpdate(name: "foo", value: "bar")
		#expect(result?.absoluteString == "http://example.com?foo=bar")
	}

	@Test func addNewToTail() {
		let url = URL(string: "http://example.com?code=1")
		let result = url?.addOrUpdate(name: "foo", value: "bar")
		#expect(result?.absoluteString == "http://example.com?code=1&foo=bar")
	}

	@Test func updateExisting() {
		let url = URL(string: "http://example.com?foo=car")
		let result = url?.addOrUpdate(name: "foo", value: "bar")
		#expect(result?.absoluteString == "http://example.com?foo=bar")
	}
}
