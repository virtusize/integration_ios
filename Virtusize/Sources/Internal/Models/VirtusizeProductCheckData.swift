//
//  VirtusizeProductCheckData.swift
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

/// This class represents the response for the API request `productDataCheck`
internal class VirtusizeProductCheckData: Codable {
	let validProduct: Bool
	let fetchMetaData: Bool
	let userData: VirtusizeUserData?
	let productDataId: Int?
	let productTypeName: String?
	let storeName: String
	let storeId: Int
	let productTypeId: Int?

	private enum CodingKeys: String, CodingKey {
		case validProduct, fetchMetaData, userData, productDataId, productTypeName, storeName, storeId, productTypeId
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		validProduct = try values.decode(Bool.self, forKey: .validProduct)
		fetchMetaData = try values.decode(Bool.self, forKey: .fetchMetaData)
		userData = try? values.decode(VirtusizeUserData.self, forKey: .userData)
		productDataId = try? values.decode(Int.self, forKey: .productDataId)
		productTypeName = try? values.decode(String.self, forKey: .productTypeName)
		storeName = try values.decode(String.self, forKey: .storeName)
		storeId = try values.decode(Int.self, forKey: .storeId)
		productTypeId = try? values.decode(Int.self, forKey: .productTypeId)
	}
}
