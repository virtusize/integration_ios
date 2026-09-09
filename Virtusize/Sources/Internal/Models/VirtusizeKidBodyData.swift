//
//  VirtusizeKidBodyData.swift
//
//  Copyright (c) 2026 Virtusize KK
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
import VirtusizeCore

/// The kid's body inputs entered in the web widget, in the units expected by
/// the `user-body-measurements-predict` API (height in mm, weight in kg, age in years).
///
/// The widget keeps these inputs on the client only, so the SDK caches them in
/// `UserDefaultsHelper` from the `user-selected-gender` and `user-updated-body-measurements`
/// events whose `source` is `kids`.
internal struct VirtusizeKidBodyData: Encodable, Equatable {
	/// The `source` value of the widget events that carry kids inputs
	static let eventSource = "kids"
	/// The gender used when the widget has not reported one
	static let defaultGender = "girl"

	/// The kid's gender ("girl" or "boy")
	let gender: String
	/// The kid's height in millimeters
	let height: Int
	/// The kid's weight in kilograms
	let weight: Int
	/// The kid's age in years
	let age: Int

	/// The cached kid's body data, or nil unless age, height and weight have all been received
	static var cached: VirtusizeKidBodyData? {
		let defaults = UserDefaultsHelper.current
		guard let age = defaults.kidAge,
			  let heightInCm = defaults.kidHeight,
			  let weight = defaults.kidWeight else {
			return nil
		}
		return VirtusizeKidBodyData(
			gender: defaults.kidGender ?? defaultGender,
			height: heightInCm * 10,
			weight: weight,
			age: age
		)
	}

	/// Overrides the cached kid's body data with the values present in a widget event.
	/// Values that are nil keep their cached value.
	///
	/// - Parameters:
	///   - gender: "girl" or "boy"
	///   - age: the age in years
	///   - height: the height in centimeters
	///   - weight: the weight in kilograms
	static func cache(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil) {
		let defaults = UserDefaultsHelper.current
		if let gender = gender, !gender.isEmpty {
			defaults.kidGender = gender
		}
		if let age = age {
			defaults.kidAge = age
		}
		if let height = height {
			defaults.kidHeight = height
		}
		if let weight = weight {
			defaults.kidWeight = weight
		}
	}

	/// Removes the cached kid's body data
	static func clearCache() {
		UserDefaultsHelper.current.deleteKidBodyData()
	}

	/// Converts a widget event value (a number or a numeric string such as "107") to an integer
	static func intValue(_ value: Any?) -> Int? {
		switch value {
		case let int as Int:
			return int
		case let double as Double:
			return Int(double.rounded())
		case let string as String:
			guard let double = Double(string.trimmingCharacters(in: .whitespaces)) else {
				return nil
			}
			return Int(double.rounded())
		default:
			return nil
		}
	}

	/// Builds the user body profile used for the kids size recommendation
	/// from the measurements returned by the `user-body-measurements-predict` API
	///
	/// - Parameter predictedMeasurements: the predicted body measurements, keyed by camelCase measurement name
	func bodyProfile(predictedMeasurements: [String: VirtusizeAnyCodable]) -> VirtusizeUserBodyProfile {
		var bodyData: [String: Int?] = [:]
		for (name, measurement) in predictedMeasurements {
			bodyData[name] = VirtusizeKidBodyData.intValue(measurement.value)
		}
		return VirtusizeUserBodyProfile(
			gender: gender,
			age: age,
			height: height,
			weight: String(weight),
			bodyData: bodyData
		)
	}
}
