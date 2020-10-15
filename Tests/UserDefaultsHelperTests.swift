//
//  UserDefaultsHelperTests.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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
import XCTest
@testable import Virtusize

class UserDefaultsHelperTests: XCTestCase {

	class MockNSUserDefaults: UserDefaults {
		let set: NSMutableDictionary = NSMutableDictionary()
		override func setValue(_ value: Any?, forKey key: String) {
			set.setValue(value, forKey: key)
		}
		override func value(forKey key: String) -> Any? {
			return set.value(forKey: key)
		}
		override func removeObject(forKey defaultName: String) {
			return set.removeObject(forKey: defaultName)
		}
		override func synchronize() -> Bool {
			return true
		}
	}

    func testBrowserIDCreatedLazily() {
		let mockDefaults = MockNSUserDefaults()
		XCTAssertNil(mockDefaults.value(forKey: "BID"))

		let installation = UserDefaultsHelper(defaults: mockDefaults)

		// there should be a identifier created if calling it
		// and it should be saved in the defaults
		XCTAssertNotNil(installation.identifier)
		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))

		let identifier: String = installation.identifier

		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))
		if let value = mockDefaults.value(forKey: "BID") as? String {
			XCTAssertEqual(value, identifier)
		}

		// verify the token does not change when asking for it again
		XCTAssertEqual(installation.identifier, identifier)
    }

    func testBrowserIDSpecified() {
		let mockDefaults = MockNSUserDefaults()
		XCTAssertNil(mockDefaults.value(forKey: "BID"))

		let installation = UserDefaultsHelper(defaults: mockDefaults)

		// there should be a identifier created if calling it
		// and it should be saved in the defaults
		XCTAssertNotNil(installation.identifier)
		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))

		let expectedIdentifier = "1234"
		installation.identifier = expectedIdentifier

		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))
		if let value = mockDefaults.value(forKey: "BID") as? String {
			XCTAssertEqual(value, expectedIdentifier)
		}

		// verify the token does not change when asking for it again
		XCTAssertEqual(installation.identifier, expectedIdentifier)
    }

    func testDeleteBrowserID() {
		let mockDefaults = MockNSUserDefaults()
		XCTAssertNil(mockDefaults.value(forKey: "BID"))

		let installation = UserDefaultsHelper(defaults: mockDefaults)

		// there should be a identifier created if calling it
		// and it should be saved in the defaults
		XCTAssertNotNil(installation.identifier)
		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))
		let previousToken = installation.identifier

		installation.deleteIdentifier()
		XCTAssertNil(mockDefaults.value(forKey: "BID"))

		// calling it again will create another identifier now
		XCTAssertNotNil(installation.identifier)

		XCTAssertNotNil(mockDefaults.value(forKey: "BID"))
		if let token = mockDefaults.value(forKey: "BID") as? String {
			XCTAssertNotEqual(token, previousToken)
		}
    }
}
