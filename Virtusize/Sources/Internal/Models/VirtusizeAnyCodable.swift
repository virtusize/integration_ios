//
//  VirtusizeAnyCodable.swift
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

internal struct VirtusizeAnyCodable {
	public var value: Any

	public init<T>(_ value: T?) {
		self.value = value ?? ()
	}
}

extension VirtusizeAnyCodable: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if container.decodeNil() {
			self.init(())
		} else if let bool = try? container.decode(Bool.self) {
			self.init(bool)
		} else if let int = try? container.decode(Int.self) {
			self.init(int)
		} else if let string = try? container.decode(String.self) {
			self.init(string)
		} else if let array = try? container.decode([VirtusizeAnyCodable].self) {
			self.init(array.map { $0.value })
		} else if let dictionary = try? container.decode([String: VirtusizeAnyCodable].self) {
			self.init(dictionary.mapValues { $0.value })
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "VirtusizeAnyCodable value cannot be decoded"
			)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		// swiftlint:disable switch_case_alignment
		switch self.value {
			case is Void:
				try container.encodeNil()
			case let bool as Bool:
				try container.encode(bool)
			case let int as Int:
				try container.encode(int)
			case let string as String:
				try container.encode(string)
			case let array as [Any?]:
				try container.encode(array.map { VirtusizeAnyCodable($0) })
			case let dictionary as [String: Any?]:
				try container.encode(dictionary.mapValues { VirtusizeAnyCodable($0) })
			default:
				let context = EncodingError.Context(
					codingPath: container.codingPath,
					debugDescription: "VirtusizeAnyCodable value cannot be encoded"
				)
				throw EncodingError.invalidValue(self.value, context)
		}
	}
}
