//
//  JSON+Exensions.swift
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

internal extension JSONObject {
	mutating func deepMerge(source: JSONObject) {
		for (key, value) in source {
			if let newJson = value as? JSONObject, let existingJson = self[key] as? JSONObject {
				// update
				var mergedDict = existingJson
				mergedDict.deepMerge(source: newJson)
				self[key] = mergedDict
			} else if let newArray = value as? [Any], let existingArray = self[key] as? [Any] {
				// attach
				self[key] = existingArray + newArray
			} else {
				// set
				self[key] = value
			}
		}
	}
}

internal extension Array where Element == String {
	/// Orders the strings the way JavaScript iterates the keys of an object keyed by them:
	/// integer-like keys (e.g. "110", "120") first in ascending numeric order, then the
	/// other keys in their original order.
	///
	/// Used to send size names in the same order as the web widget, since the
	/// size recommendation API result depends on it.
	func sortedLikeJavaScriptObjectKeys() -> [String] {
		func integerKey(_ key: String) -> UInt32? {
			// JavaScript treats only canonical non-negative integers below 2^32 - 1 as index keys
			guard let value = UInt32(key), String(value) == key, value < UInt32.max else {
				return nil
			}
			return value
		}
		let integerKeys = self
			.compactMap { key in integerKey(key).map { (key: key, index: $0) } }
			.sorted { $0.index < $1.index }
			.map { $0.key }
		let otherKeys = filter { integerKey($0) == nil }
		return integerKeys + otherKeys
	}
}

/// A minimal JSON value whose object keys are serialized in insertion order.
/// `JSONEncoder` and `JSONSerialization` do not preserve key order on iOS 15/16.
internal indirect enum OrderedJSONValue {
	case object([(String, OrderedJSONValue)])
	case array([OrderedJSONValue])
	case string(String)
	case int(Int)
	case bool(Bool)
	case null

	/// The JSON text of this value
	var serialized: String {
		switch self {
		case .object(let pairs):
			let members = pairs.map { "\"\(OrderedJSONValue.escape($0.0))\":\($0.1.serialized)" }
			return "{\(members.joined(separator: ","))}"
		case .array(let values):
			return "[\(values.map { $0.serialized }.joined(separator: ","))]"
		case .string(let string):
			return "\"\(OrderedJSONValue.escape(string))\""
		case .int(let int):
			return String(int)
		case .bool(let bool):
			return bool ? "true" : "false"
		case .null:
			return "null"
		}
	}

	/// Escapes a string for use inside JSON quotes
	static func escape(_ string: String) -> String {
		var escaped = ""
		for scalar in string.unicodeScalars {
			switch scalar {
			case "\"":
				escaped += "\\\""
			case "\\":
				escaped += "\\\\"
			case "\n":
				escaped += "\\n"
			case "\r":
				escaped += "\\r"
			case "\t":
				escaped += "\\t"
			case _ where scalar.value < 0x20:
				escaped += String(format: "\\u%04x", scalar.value)
			default:
				escaped.unicodeScalars.append(scalar)
			}
		}
		return escaped
	}
}
