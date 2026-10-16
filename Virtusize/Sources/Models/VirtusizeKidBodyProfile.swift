//
//  VirtusizeKidBodyProfile.swift
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

/// Kids widget inputs: age, weight, gender and height.
/// Predicted measurements are stored separately as `VirtusizeUserBodyProfile.cachedKidPrediction`.
public class VirtusizeKidBodyProfile: Codable {
	/// The `source` value of kids widget events
	static let kidsEventSource = "kids"
	/// The gender used when the kids widget has not reported one
	static let defaultKidsGender = "girl"

	/// The kid's gender
	let gender: String
	/// The kid's age
	let age: Int?
	/// The kid's height in millimeters
	let height: Int?
	/// The kid's weight
	let weight: String?
	/// Predicted body measurements, keyed by measurement name
	let bodyData: [String: Int?]?

	internal init(
		gender: String,
		age: Int?,
		height: Int?,
		weight: String?,
		bodyData: [String: Int?]? = nil
	) {
		self.gender = gender
		self.age = age
		self.height = height
		self.weight = weight
		self.bodyData = bodyData
	}

	/// Age, height and weight are present so kids size can be predicted
	var hasKidPredictInputs: Bool {
		guard let age = age, let height = height, let weight = weight, Int(weight) != nil else {
			return false
		}
		return age > 0 && height > 0 && !weight.isEmpty
	}

	/// Payload for `user-body-measurements-predict` (gender, height mm, weight kg, age)
	func predictParams() -> [String: Any]? {
		guard hasKidPredictInputs, let age = age, let height = height, let weight = weight, let weightKg = Int(weight) else {
			return nil
		}
		let gender = self.gender.isEmpty ? Self.defaultKidsGender : self.gender
		return [
			"gender": gender,
			"height": height,
			"weight": weightKg,
			"age": age
		]
	}

	/// The cached kids profile, if one has been stored
	static var cached: VirtusizeKidBodyProfile? {
		guard let data = UserDefaultsHelper.current.kidBodyProfileData else {
			return nil
		}
		return try? JSONDecoder().decode(VirtusizeKidBodyProfile.self, from: data)
	}

	/// Stores the whole kids profile in user defaults
	static func cache(_ profile: VirtusizeKidBodyProfile) {
		UserDefaultsHelper.current.kidBodyProfileData = try? JSONEncoder().encode(profile)
	}

	/// Kids widget events whose `source` is `kids`
	static func isKidsEvent(_ eventData: [String: Any]?) -> Bool {
		return eventData?["source"] as? String == kidsEventSource
	}

	/// Overrides gender/age/height/weight from a kids widget event. Height is in centimeters
	/// in the event and stored in millimeters. Absent values keep their cached value.
	static func cacheKidsEvent(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil) {
		let current = cached
		let next = VirtusizeKidBodyProfile(
			gender: {
				if let gender = gender, !gender.isEmpty { return gender }
				return current?.gender.isEmpty == false ? current!.gender : defaultKidsGender
			}(),
			age: age ?? current?.age,
			height: height.map { $0 * 10 } ?? current?.height,
			weight: weight.map { String($0) } ?? current?.weight
		)
		cache(next)
	}

	/// Removes the cached kids profile
	static func clearCache() {
		UserDefaultsHelper.current.deleteKidBodyProfile()
	}

	/// Converts a widget event value (a number or a numeric string such as "107") to an integer
	static func intValue(_ value: Any?) -> Int? {
		switch value {
		case let int as Int:
			return int
		case let double as Double:
			return Int(double.rounded())
		case let object as [String: Any]:
			return intValue(object["_value"])
		case let string as String:
			guard let double = Double(string.trimmingCharacters(in: .whitespaces)) else {
				return nil
			}
			return Int(double.rounded())
		default:
			return nil
		}
	}

	/// The profile used for the kids size recommendation, built from predicted measurements.
	/// This does not write the adult/shoe `VirtusizeUserBodyProfile` cache.
	func applyingPredictedMeasurements(_ predictedMeasurements: [String: VirtusizeAnyCodable]) -> VirtusizeUserBodyProfile {
		var bodyData: [String: Int?] = [:]
		for (name, measurement) in predictedMeasurements {
			bodyData[name] = Self.intValue(measurement.value)
		}
		return VirtusizeUserBodyProfile(
			gender: gender.isEmpty ? Self.defaultKidsGender : gender,
			age: age,
			height: height,
			weight: weight,
			bodyData: bodyData
		)
	}
}
