//
//  JsonExtensionTests.swift
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

import Testing
@testable import Virtusize

struct JsonExtensionTests {
	@Test func addNew() {
		var json: JSONObject = ["a": 1]
		json.deepMerge(source: ["b": 2])
		#expect(json as NSDictionary == ["a": 1, "b": 2])
	}

	@Test func updateExisting() {
		var json: JSONObject = ["a": 1]
		json.deepMerge(source: ["a": 2])
		#expect(json as NSDictionary == ["a": 2])
	}

	@Test func sortedLikeJavaScriptObjectKeys() {
		#expect(["M", "160", "S", "110", "L", "90"].sortedLikeJavaScriptObjectKeys() == ["90", "110", "160", "M", "S", "L"])
		#expect(
			["140", "130", "110", "160", "120", "150"].sortedLikeJavaScriptObjectKeys()
				== ["110", "120", "130", "140", "150", "160"]
		)
		// Non-canonical numbers are not index keys in JavaScript and keep their position
		#expect(["090", "10", "-1", "1.5"].sortedLikeJavaScriptObjectKeys() == ["10", "090", "-1", "1.5"])
	}

	@Test func sizeMapsFollowClientSizeOrder() throws {
		let payload: [String: Any] = [
			"items": [[
				"additional_info": [
					"client_size_order": ["J/XS", "J/S", "J/M", "J/L", "J/XL"],
					"sizes": ["S": ["bust": 380], "XL": ["bust": 435], "XS": ["bust": 360], "L": ["bust": 420], "M": ["bust": 400]]
				],
				"item_sizes_orig": ["J/XL": ["bust": 435], "J/S": ["bust": 380], "J/XS": ["bust": 360], "J/L": ["bust": 420], "J/M": ["bust": 400]]
			]]
		]
		let data = try JSONSerialization.data(withJSONObject: payload)
		let ordered = String(data: jsonWithOrderedSizeMaps(data)!, encoding: .utf8)!
		#expect(ordered.contains("\"item_sizes_orig\":{\"J/XS\":"))
		#expect(ordered.contains("\"sizes\":{\"XS\":"))
		let itemStart = ordered.range(of: "\"item_sizes_orig\":{")!.upperBound
		let item = ordered[itemStart...]
		#expect(item.range(of: "\"J/XS\":")!.lowerBound < item.range(of: "\"J/S\":")!.lowerBound)
		#expect(item.range(of: "\"J/S\":")!.lowerBound < item.range(of: "\"J/M\":")!.lowerBound)
		#expect(item.range(of: "\"J/M\":")!.lowerBound < item.range(of: "\"J/L\":")!.lowerBound)
		let sizesStart = ordered.range(of: "\"sizes\":{")!.upperBound
		let sizes = ordered[sizesStart...]
		#expect(sizes.range(of: "\"XS\":")!.lowerBound < sizes.range(of: "\"S\":")!.lowerBound)
		#expect(sizes.range(of: "\"S\":")!.lowerBound < sizes.range(of: "\"M\":")!.lowerBound)
		#expect(sizes.range(of: "\"M\":")!.lowerBound < sizes.range(of: "\"L\":")!.lowerBound)
	}

	@Test func orderedJSONValueSerializesAndEscapes() throws {
		let value = OrderedJSONValue.object([
			("b", .array([.int(1), .bool(false), .null])),
			("a", .string("quote\" backslash\\ newline\n tab\t ctrl\u{01} 日本"))
		])
		#expect(value.serialized == "{\"b\":[1,false,null],\"a\":\"quote\\\" backslash\\\\ newline\\n tab\\t ctrl\\u0001 日本\"}")
		let parsed = try JSONSerialization.jsonObject(with: value.serialized.data(using: .utf8)!) as? [String: Any]
		#expect(parsed?["a"] as? String == "quote\" backslash\\ newline\n tab\t ctrl\u{01} 日本")
	}

	@Test func updateDeepObject() {
		var json: JSONObject = ["a": 1, "b": ["c": 2, "d": 3]]
		json.deepMerge(source: ["b": ["c": 4]])
		#expect(json as NSDictionary == ["a": 1, "b": ["c": 4, "d": 3]])
	}

	@Test func mergeArrays() {
		var json: JSONObject = ["a": [1, 2]]
		json.deepMerge(source: ["a": [3]])
		#expect(json as NSDictionary == ["a": [1, 2, 3]])
	}
}
