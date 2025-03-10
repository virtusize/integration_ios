//
//  VirtusizeProduct.swift
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
import VirtusizeCore

/// This structure represents a product in the Virtusize SDK
public class VirtusizeProduct: Codable {

	/// The product name
	internal var name: String = ""

	/// A string to represent the ID that will be used to reference this product in Virtusize API
	public var externalId: String = ""

	/// The URL of the product image that is fully qualified with the domain and the protocol
	public var imageURL: URL?

	/// The product data from the response of the `productCheck` request
	internal var productCheckData: VirtusizeProductCheckData?

	/// The product data as a `JSONObject`
	internal var jsonObject: JSONObject? {
		return try? JSONSerialization.jsonObject(
			with: JSONEncoder().encode(self),
			options: .allowFragments
		) as? JSONObject
	}

	/// An integer to represent the internal product ID in the Virtusize server
	public var id: Int? {
		return productCheckData?.productDataId
	}

	/// The product data as a dictionary
	public var dictionary: [String: Any] {
		return jsonObject ?? [:]
	}

	/// Initializes the VirtusizeProduct structure
	internal init(externalId: String, imageURL: URL?, productCheckData: VirtusizeProductCheckData?) {
		self.externalId = externalId
		self.imageURL = imageURL
		self.productCheckData = productCheckData
	}

	private enum CodingKeys: String, CodingKey {
		case name
		case externalId = "productId"
		case productCheckData = "data"
	}

	required public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decode(String.self, forKey: .name)
		externalId = try values.decode(String.self, forKey: .externalId)
		productCheckData = try? values.decode(VirtusizeProductCheckData.self, forKey: .productCheckData)
	}
}

extension VirtusizeProduct {
	public convenience init(externalId: String, imageURL: URL? = nil) {
		self.init(externalId: externalId, imageURL: imageURL, productCheckData: nil)
	}
}

extension VirtusizeProduct: Hashable {
	public static func == (lhs: VirtusizeProduct, rhs: VirtusizeProduct) -> Bool {
		return lhs.externalId == rhs.externalId
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(externalId)
	}
}
