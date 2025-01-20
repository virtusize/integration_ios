//
//  GoogleUser.swift
//  VirtusizeAuth
//
//  Copyright (c) 2021-present Virtusize KK
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

/// Google user model
class GoogleUser: Codable, VirtusizeUser {
	/// The user's unique ID
	let sub: String
	/// The user's given name
	let givenName: String?
	/// The user's family name
	let familyName: String?
	/// The user's full name
	let name: String
	/// The user's locale
	let locale: String?
	/// The user's profile picture URL
	let pictureUrl: String?
	/// The user's email
	let email: String

	var id: String {
		return self.sub
	}

	var snsType: String {
		return SNSType.google.rawValue
	}

	private enum CodingKeys: String, CodingKey {
		case sub
		case givenName = "given_name"
		case familyName = "family_name"
		case name
		case locale
		case pictureUrl = "picture"
		case email
	}
}
