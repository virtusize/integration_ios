//
//  UserDefaultsHelper.swift
//
//  Copyright (c) 2018 Virtusize KK
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

/// This class is used to get the browser identifier and the auth header specific to this SDK
final public class UserDefaultsHelper {

	let authKey = "VIRTUSIZE_AUTH"
	let tokenKey = "VIRTUSIZE_TOKEN"
	let bidKey = "BID"
	let userBodyProfileKey = "VIRTUSIZE_USER_BODY_PROFILE"
	let kidBodyProfileKey = "VIRTUSIZE_KID_BODY_PROFILE"
	let kidPredictedBodyProfileKey = "VIRTUSIZE_KID_PREDICTED_BODY_PROFILE"
    public let undefinedValue = "undefined"

	/// A static instance of `UserDefaultsHelper` used inside the SDK
	public static let current = UserDefaultsHelper()

	/// 'UserDefaults' to save the browser identifier locally
	internal var defaults: UserDefaults

	/// Initializes the 'UserDefaultsHelper' class and sets up the global instance of `UserDefaults`
	init() {
		self.defaults = UserDefaults.standard
	}

	/// Initializes the 'UserDefaultsHelper' class with a passing argument as `UserDefaults`
	init(defaults: UserDefaults) {
		self.defaults = defaults
	}

	/// The auth token for the session API
	public var authToken: String? {
		get {
			return defaults.value(forKey: authKey) as? String
		}
		set {
			defaults.setValue(newValue, forKey: authKey)
			defaults.synchronize()
		}
	}

	/// The access token for the API requests to get user data
	public var accessToken: String? {
		get {
			return defaults.value(forKey: tokenKey) as? String
		}
		set {
			defaults.setValue(newValue, forKey: tokenKey)
			defaults.synchronize()
		}
	}

	/// The browser identifier as String
	public var identifier: String {
		get {
            if let token = defaults.value(forKey: bidKey) as? String, token != undefinedValue {
				return token
			} else {
				let token = generateIdentifier()
				defaults.setValue(token, forKey: bidKey)
				defaults.synchronize()
				return token
			}
		}
		set {
			defaults.setValue(newValue, forKey: bidKey)
			defaults.synchronize()
		}
	}

	/// Deletes the browser identifier from the user defaults
	internal func deleteIdentifier() {
		defaults.removeObject(forKey: bidKey)
		defaults.synchronize()
	}

	// MARK: - Cached body profiles
	// 1. `VirtusizeKidBodyProfile`: kids age, weight, gender and height from widget events.
	// 2. `kidPredictedBodyProfileData`: predicted kids measurements.
	// 3. `userBodyProfileData`: adult and shoe `getUserBodyProfileAsync` response.

	/// The encoded user body profile, or nil if none is cached
	public var userBodyProfileData: Data? {
		get {
			return defaults.value(forKey: userBodyProfileKey) as? Data
		}
		set {
			defaults.setValue(newValue, forKey: userBodyProfileKey)
			defaults.synchronize()
		}
	}

	/// Deletes the cached user body profile
	public func deleteUserBodyProfile() {
		defaults.removeObject(forKey: userBodyProfileKey)
		defaults.synchronize()
	}

	/// The encoded kids body profile, or nil if none is cached
	public var kidBodyProfileData: Data? {
		get {
			return defaults.value(forKey: kidBodyProfileKey) as? Data
		}
		set {
			defaults.setValue(newValue, forKey: kidBodyProfileKey)
			defaults.synchronize()
		}
	}

	/// Deletes the cached kids body profile
	public func deleteKidBodyProfile() {
		defaults.removeObject(forKey: kidBodyProfileKey)
		defaults.synchronize()
	}

	/// The encoded predicted kids measurements, or nil if none are cached
	public var kidPredictedBodyProfileData: Data? {
		get {
			return defaults.value(forKey: kidPredictedBodyProfileKey) as? Data
		}
		set {
			defaults.setValue(newValue, forKey: kidPredictedBodyProfileKey)
			defaults.synchronize()
		}
	}

	/// Deletes the cached predicted kids measurements
	public func deleteKidPredictedBodyProfile() {
		defaults.removeObject(forKey: kidPredictedBodyProfileKey)
		defaults.synchronize()
	}

	/// A method to generate a random string for the Browser Identifier
	///
	/// The string contains 23 random characters and 6 generated characters based on the current time
	/// in milliseconds separated with a '.'
	/// For example, cJhf5nGjDA0fgUXLAIz5Ls5.pfa1lp is a generated browser identifier
	///
	/// - Returns: A browser identifier as String
	private func generateIdentifier() -> String {
		let randomPart: String = {
			var ret: String = ""
			let chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
			let max = chars.count
			for _ in 0..<22 {
				let randomNumber = Int.random(in: 0..<max)
				let randomIndex = chars.index(chars.startIndex, offsetBy: randomNumber)
				let newCharacter = chars[randomIndex]
				ret += String(newCharacter)
			}
			return ret
		}()

		let timeSince1970InMS = Int64(Date().timeIntervalSince1970 * 1000)
		let datePart = String(timeSince1970InMS, radix: 36, uppercase: false)

		return randomPart + "." + datePart
	}
}
