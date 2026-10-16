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

import Foundation

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
	case double(Double)
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
		case .double(let double):
			return String(double)
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

/// Re-serializes JSON so `item_sizes_orig` and `additional_info.sizes` follow `client_size_order`.
/// `JSONEncoder` stores those maps in a dictionary, and the size API walks that order when fit scores tie.
internal func jsonWithOrderedSizeMaps(_ data: Data) -> Data? {
	guard let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else {
		return nil
	}
	return OrderedJSONValue.fromJSONObject(object).serialized.data(using: .utf8)
}

extension OrderedJSONValue {
	/// Rebuilds a `JSONSerialization` value. Size charts are emitted in `client_size_order`.
	/// Names such as `XS` follow `J/XS`. Integer names such as `2430` follow JavaScript key order,
	/// which is how `client_size_order` is built. Every other object keeps the parsed key order.
	static func fromJSONObject(_ value: Any, sizeOrder: [String]? = nil) -> OrderedJSONValue {
		if value is NSNull {
			return .null
		}
		if let dictionary = value as? [String: Any] {
			let keys = sizeOrder.map { orderSizeKeys(Array(dictionary.keys), clientOrder: $0) }
				?? Array(dictionary.keys)
			let nestedOrder = clientSizeOrder(in: dictionary)
			return .object(keys.map { key in
				guard let child = dictionary[key] else {
					return (key, .null)
				}
				let childOrder = (key == "item_sizes_orig" || key == "sizes") ? (nestedOrder ?? sizeOrder) : nil
				return (key, fromJSONObject(child, sizeOrder: childOrder))
			})
		}
		if let array = value as? [Any] {
			return .array(array.map { fromJSONObject($0) })
		}
		if let string = value as? String {
			return .string(string)
		}
		if let number = value as? NSNumber {
			if CFGetTypeID(number) == CFBooleanGetTypeID() {
				return .bool(number.boolValue)
			}
			let double = number.doubleValue
			if double.rounded() == double, double >= Double(Int.min), double <= Double(Int.max) {
				return .int(number.intValue)
			}
			return .double(double)
		}
		return .null
	}
}

/// `client_size_order` on this object, or on its `additional_info`.
private func clientSizeOrder(in dictionary: [String: Any]) -> [String]? {
	if let order = stringList(dictionary["client_size_order"]) {
		return order
	}
	if let info = dictionary["additional_info"] as? [String: Any] {
		return stringList(info["client_size_order"])
	}
	return nil
}

private func stringList(_ value: Any?) -> [String]? {
	if let strings = value as? [String] {
		return strings
	}
	guard let values = value as? [Any] else { return nil }
	let strings = values.compactMap { $0 as? String }
	return strings.count == values.count ? strings : nil
}

/// Size-chart key order. Exact names win. `XS` is matched to `J/XS` by the longest suffix.
private func orderSizeKeys(_ keys: [String], clientOrder: [String]) -> [String] {
	var remaining = Set(keys)
	var ordered: [String] = []
	for name in clientOrder {
		guard let match = bestSizeKey(in: remaining, for: name) else { continue }
		ordered.append(match)
		remaining.remove(match)
	}
	ordered.append(contentsOf: Array(remaining).sortedLikeJavaScriptObjectKeys())
	return ordered
}

private func bestSizeKey(in keys: Set<String>, for clientName: String) -> String? {
	if keys.contains(clientName) {
		return clientName
	}
	return keys
		.filter { clientName.hasSuffix("/\($0)") || clientName.hasSuffix($0) }
		.max { $0.count < $1.count }
}
