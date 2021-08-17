//
//  VirtusizeOrder.swift
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

/// This structure wraps the parameters for the API request of sending the order
public struct VirtusizeOrder: Codable {
	/// The API key that is unique and provided for Virtusize clients
	internal var apiKey: String?
	/// The order ID provided by the client
	private let externalOrderId: String
	/// The unique user ID from the client system.
	/// `Virtusize.userId` should be set for sending the order
	internal var externalUserId: String?
	/// A country code is set for each region i.e. ISO-3166.
	/// This is set by the response of the request that retrieves the specific store info
	internal var region: String?
	/// An array of the order items.
	public var items: [VirtusizeOrderItem]

	/// Initializes the VirtusizeOrder structure
	private init(
		externalOrderId: String,
		externalUserId: String? = nil,
		region: String? = nil,
		items: [VirtusizeOrderItem] = []
	) {
		self.apiKey = Virtusize.APIKey
		self.externalOrderId = externalOrderId
		self.externalUserId = externalUserId
		self.region = region
		self.items = items
	}

	/// Converts a dictionary to a VirtusizeOrder object
	internal static func convertToObjectBy(dictionary: [String: Any?]) -> VirtusizeOrder? {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
			return try JSONDecoder().decode(VirtusizeOrder.self, from: jsonData)
		} catch {
			return nil
		}
	}
}

extension VirtusizeOrder {
	public init(externalOrderId: String) {
		self.init(externalOrderId: externalOrderId, externalUserId: nil, region: nil, items: [])
	}

	public init(externalOrderId: String, items: [VirtusizeOrderItem]) {
		self.init(externalOrderId: externalOrderId, externalUserId: nil, region: nil, items: items)
	}
}
