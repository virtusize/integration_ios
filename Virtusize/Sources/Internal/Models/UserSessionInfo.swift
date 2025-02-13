//
//  UserSessionInfo.swift
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

/// This class represents the user session information
internal class UserSessionInfo: Codable {
	/// The access token
	let accessToken: String
	/// The user data
	let user: User
	/// The auth token
	let authToken: String
	/// The user status data
	let status: Status

	class User: Codable {
		/// The browser ID
		let bid: String
	}

	class Status: Codable {
		/// The flag to indicate if user defined body measurements
		let hasBodyMeasurement: Bool
	}

	private enum CodingKeys: String, CodingKey {
		case accessToken = "id"
		case user = "user"
		case authToken = "x-vs-auth"
		case status = "status"
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		accessToken = try values.decode(String.self, forKey: .accessToken)
		user = try values.decode(User.self, forKey: .user)
		authToken = try values.decode(String.self, forKey: .authToken)
		status = try values.decode(Status.self, forKey: .status)
	}
}
