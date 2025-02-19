//
//  VirtusizeAuthProvider.swift
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

/// The protocol that all SNS Auth providers must conform to.
protocol VirtusizeAuthProvider {
	/// Gets the user's information from the provider with an access token.
	func getUserInfo(accessToken: String) async -> VirtusizeUser?
}

/// Facebook Auth Provider
class FacebookAuthProvider: VirtusizeAuthProvider {
	func getUserInfo(accessToken: String) async -> VirtusizeUser? {
		return await FacebookAPIService.getUserInfoAsync(accessToken: accessToken).success
	}
}

/// Google Auth Provider
class GoogleAuthProvider: VirtusizeAuthProvider {
	func getUserInfo(accessToken: String) async -> VirtusizeUser? {
		return await GoogleAPIService.getUserInfoAsync(accessToken: accessToken).success
	}
}
