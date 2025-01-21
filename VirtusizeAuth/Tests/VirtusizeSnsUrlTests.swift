//
//  JsonTests.swift
//  VirtusizeAuthTests
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
import Testing
@testable import VirtusizeAuth

struct VirtusizeSnsUrlTests {

	@Test func appendJson() {
		let json = "{\"state\":\"xxx\"}"
		let newJson = VirtusizeAuthStringHelper.appendJsonFieldTo(jsonString: json, key: "foo", value: "bar")
		expectJsonMatch(newJson, "{\"foo\":\"bar\",\"state\":\"xxx\"}")
	}

	@Test func extendStateAsJson() {
		let url = "https://example.com?state={\"state\":\"xxx\"}"
		let newUrl = VirtusizeAuthorization.shared.updateUrlStateWithProperty(urlString: url, key: "foo", value: "bar")
			.removingPercentEncoding
		expectUrlWithJsonParamMatch(
			newUrl,
			"https://example.com?state={\"state\":\"xxx\",\"foo\":\"bar\"}",
			paramName: "state")
	}

	@Test func convertStateToJson() {
		let url = "https://example.com?state=xxx"
		let newUrl = VirtusizeAuthorization.shared.updateUrlStateWithProperty(urlString: url, key: "foo", value: "bar")
			.removingPercentEncoding
		expectUrlWithJsonParamMatch(
			newUrl,
			"https://example.com?state={\"state\":\"xxx\",\"foo\":\"bar\"}",
			paramName: "state")
	}

	@Test func injectEnvAndRegion() {
		let url = "https://example.com"
		let newUrl = VirtusizeAuthorization.shared.updateUrlWithEnvironment(urlString: url, region: "jp", env: "testing")
			.removingPercentEncoding
		expectUrlWithJsonParamMatch(
			newUrl,
			"https://example.com?state={\"region\":\"jp\",\"env\":\"testing\"}",
			paramName: "state")
	}

	@Test func injectSnsType() {
		let url = "https://facebook.com"
		let newUrl = VirtusizeAuthorization.shared.updateUrlWithSnsType(urlString: url)
			.removingPercentEncoding
		#expect(newUrl == "https://facebook.com?state={\"sns_type\":\"facebook\"}")
	}

}
