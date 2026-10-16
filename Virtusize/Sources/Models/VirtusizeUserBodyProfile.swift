//
//  VirtusizeUserBodyProfile.swift
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
import VirtusizeCore

/// This class represents a body-measurements profile.
/// Adult and shoe responses and predicted kids measurements are cached separately.
public class VirtusizeUserBodyProfile: Codable {
	/// The user's gender
	let gender: String
	/// The user's age
	let age: Int?
	/// The user's height
	let height: Int?
	/// The user's weight
	let weight: String?
	/// The user's body measurement data, such as hip, bust, waist and so on.
	let bodyData: [String: Int?]?
	/// The user's footwear data, such as shoe size and width
    let footwearData: [String: VirtusizeAnyCodable]?
	/// The user's bra size information
	let braSize: [String: VirtusizeAnyCodable?]?
	let origin: String?

	internal init(
		gender: String,
		age: Int?,
		height: Int?,
		weight: String?,
		bodyData: [String: Int?]?,
		footwearData: [String: VirtusizeAnyCodable]? = nil,
		braSize: [String: VirtusizeAnyCodable?]? = nil,
		origin: String? = nil
	) {
		self.gender = gender
		self.age = age
		self.height = height
		self.weight = weight
		self.bodyData = bodyData
		self.footwearData = footwearData
		self.braSize = braSize
		self.origin = origin
	}

	/// The cached adult/shoe profile, if one has been stored
	static var cached: VirtusizeUserBodyProfile? {
		guard let data = UserDefaultsHelper.current.userBodyProfileData else {
			return nil
		}
		return try? JSONDecoder().decode(VirtusizeUserBodyProfile.self, from: data)
	}

	/// Stores the whole profile in user defaults
	static func cache(_ profile: VirtusizeUserBodyProfile) {
		UserDefaultsHelper.current.userBodyProfileData = try? JSONEncoder().encode(profile)
	}

	/// Removes the cached adult/shoe profile
	static func clearCache() {
		UserDefaultsHelper.current.deleteUserBodyProfile()
	}

	/// The cached predicted kids measurements, if they have been stored
	static var cachedKidPrediction: VirtusizeUserBodyProfile? {
		guard let data = UserDefaultsHelper.current.kidPredictedBodyProfileData else {
			return nil
		}
		return try? JSONDecoder().decode(VirtusizeUserBodyProfile.self, from: data)
	}

	/// Stores the predicted kids measurements
	static func cacheKidPrediction(_ profile: VirtusizeUserBodyProfile) {
		UserDefaultsHelper.current.kidPredictedBodyProfileData = try? JSONEncoder().encode(profile)
	}

	/// Removes the cached predicted kids measurements
	static func clearKidPrediction() {
		UserDefaultsHelper.current.deleteKidPredictedBodyProfile()
	}
}
