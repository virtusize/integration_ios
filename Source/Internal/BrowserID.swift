//
//  BrowserID.swift
//
//  Copyright (c) 2018 Virtusize AB
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

internal class BrowserID {

	internal static let current = BrowserID()

	internal var defaults: UserDefaults

	init() {
		self.defaults = UserDefaults.standard
	}

	init(defaults: UserDefaults) {
		self.defaults = defaults
	}

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

	internal func deleteIdentifier() {
		defaults.removeObject(forKey: "BID")
		defaults.synchronize()
	}

	private func generateIdentifier() -> String {
		let randomPart: String = {
			var ret: String = ""
			let chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
			for _ in 0..<22 {
				let max = UInt32(chars.count)
				let randomNumber = Int(arc4random_uniform(max))
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
