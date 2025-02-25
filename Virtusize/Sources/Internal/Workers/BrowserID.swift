//
//  BrowserID.swift
//
//  Copyright (c) 2018-present Virtusize KK
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

/// This class is used to get the browser identifier specific to this SDK
final internal class BrowserID {

    /// A static instance of `BrowserID` used inside the SDK
	internal static let current = BrowserID()

    /// 'UserDefaults' to save the browser identifier locally
	internal var defaults: UserDefaults

    /// Initializes the 'BrowserID' class and sets up the global instance of `UserDefaults`
	init() {
		self.defaults = UserDefaults.standard
	}

    /// Initializes the 'BrowserID' class with a passing argument as `UserDefaults`
	init(defaults: UserDefaults) {
		self.defaults = defaults
	}

    /// Gets a browser identifier as String
    internal var identifier: String {
        get {
			if let token = defaults.value(forKey: "BID") as? String {
				return token
			} else {
				let token = generateIdentifier()
				defaults.setValue(token, forKey: "BID")
				defaults.synchronize()
				return token
			}
        }
        set {
			defaults.setValue(newValue, forKey: "BID")
			defaults.synchronize()
        }
    }

    /// Deletes the Browser Identifier from the user defaults
	internal func deleteIdentifier() {
		defaults.removeObject(forKey: "BID")
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
