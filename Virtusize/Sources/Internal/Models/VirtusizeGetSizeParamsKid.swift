//
//  VirtusizeGetSizeParamsKid.swift
//
//  Copyright (c) 2026 Virtusize KK
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

/// Parameters for the kids size recommendation API (`/kid`), matching the Aoyama widget payload.
internal struct VirtusizeGetSizeParamsKid: Encodable {
	struct Product: Encodable {
		var brand: String
		var gender: String
		var productType: String
		var sizeNames: [String]
		var sizeMeasurements: [String: [String: Int?]]?

		enum CodingKeys: String, CodingKey {
			case brand, gender, productType, sizeNames
			case sizeMeasurements = "size_measurements"
		}
	}

	struct User: Encodable {
		var gender: String
		var height: Int?
		var weight: Int?
		var age: Int?
		var bodyData: [String: [String: VirtusizeAnyCodable]]
	}

	var product: Product
	var user: User
	var extProductId: String

	enum CodingKeys: String, CodingKey {
		case product, user
		case extProductId = "ext_product_id"
	}

	init(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile?
	) {
		var productType = ""
		if let index = productTypes.firstIndex(where: { $0.id == storeProduct.productType }) {
			productType = productTypes[index].name
		}

		let gender = storeProduct.storeProductMeta?.additionalInfo?.gender
			?? storeProduct.storeProductMeta?.gender
			?? ""
		let brand = storeProduct.storeProductMeta?.additionalInfo?.brand
			?? storeProduct.storeProductMeta?.brand
			?? ""
		let sizeMeasurements = getItemSizesDict(storeProduct: storeProduct)
		let sizeNames = storeProduct.sizes.compactMap { $0.name }.filter { !$0.isEmpty }

		product = Product(
			brand: brand,
			gender: gender,
			productType: productType,
			sizeNames: sizeNames.isEmpty ? Array(sizeMeasurements.keys) : sizeNames,
			sizeMeasurements: sizeMeasurements
		)

		let weight = userBodyProfile?.weight.flatMap { Double($0) }.map { Int($0.rounded()) }
		user = User(
			gender: userBodyProfile?.gender ?? "",
			height: userBodyProfile?.height,
			weight: weight,
			age: userBodyProfile?.age,
			bodyData: getBodyDataDict(userBodyProfile: userBodyProfile)
		)
		extProductId = storeProduct.externalId
	}
}
