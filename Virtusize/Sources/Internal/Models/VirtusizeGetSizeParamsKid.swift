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
///
/// The `/kid` API result depends on the order of `sizeNames` and of the `size_measurements` keys,
/// and `JSONEncoder` does not preserve dictionary key order on iOS 15/16. The payload is therefore
/// serialized with `OrderedJSONValue`, in the order the web widget sends (see `sortedLikeJavaScriptObjectKeys`).
internal struct VirtusizeGetSizeParamsKid {
	struct Product {
		var brand: String
		var gender: String
		var productType: String
		/// The size names in the web widget's order
		var sizeNames: [String]
		/// The `additionalInfo.sizes` measurements, keyed by size name in the web widget's order
		var sizeMeasurements: [(name: String, measurements: [String: Int?])]?
	}

	struct User {
		var gender: String
		var height: Int?
		var weight: Int?
		var age: Int?
		/// The predicted body measurements keyed by camelCase measurement name
		var bodyData: [String: Int]
	}

	var product: Product
	var user: User
	var extProductId: String

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

		// The web widget sends `additionalInfo.sizes` as-is (e.g. only height/bust/sleeve),
		// not the full product size list, and omits it when `itemMeasurements` is false
		let additionalInfo = storeProduct.storeProductMeta?.additionalInfo
		let hasItemMeasurements = additionalInfo?.itemMeasurements ?? true
		let sizes = hasItemMeasurements ? additionalInfo?.sizes : nil

		let productSizeNames = storeProduct.sizes.compactMap { $0.name }.filter { !$0.isEmpty }
		// The widget iterates a JavaScript object keyed by size name, so the sizes go out in that order
		let sizeNames = (productSizeNames.isEmpty ? (sizes?.keys.sorted() ?? []) : productSizeNames)
			.sortedLikeJavaScriptObjectKeys()
		var sizeMeasurements: [(name: String, measurements: [String: Int?])]?
		if let sizes = sizes {
			// Sizes known to the product first, in the web widget's order, then any extra keys
			let extraNames = sizes.keys.filter { !sizeNames.contains($0) }.sorted()
			sizeMeasurements = (sizeNames + extraNames).compactMap { name in
				sizes[name].map { (name: name, measurements: $0) }
			}
		}

		product = Product(
			brand: brand,
			gender: gender,
			productType: productType,
			sizeNames: sizeNames,
			sizeMeasurements: sizeMeasurements
		)

		let weight = userBodyProfile?.weight.flatMap { Double($0) }.map { Int($0.rounded()) }
		user = User(
			gender: userBodyProfile?.gender ?? "",
			height: userBodyProfile?.height,
			weight: weight,
			age: userBodyProfile?.age,
			bodyData: (userBodyProfile?.bodyData ?? [:]).compactMapValues { $0 }
		)
		extProductId = storeProduct.externalId
	}

	/// The payload as an ordered JSON value
	var jsonValue: OrderedJSONValue {
		var productPairs: [(String, OrderedJSONValue)] = [
			("brand", .string(product.brand)),
			("gender", .string(product.gender)),
			("productType", .string(product.productType)),
			("sizeNames", .array(product.sizeNames.map { .string($0) }))
		]
		if let sizeMeasurements = product.sizeMeasurements {
			productPairs.append(("size_measurements", .object(sizeMeasurements.map { size in
				(size.name, .object(size.measurements.keys.sorted().map { key in
					(key, size.measurements[key].flatMap { $0 }.map { OrderedJSONValue.int($0) } ?? .null)
				}))
			})))
		}

		var userPairs: [(String, OrderedJSONValue)] = [("gender", .string(user.gender))]
		if let height = user.height {
			userPairs.append(("height", .int(height)))
		}
		if let weight = user.weight {
			userPairs.append(("weight", .int(weight)))
		}
		if let age = user.age {
			userPairs.append(("age", .int(age)))
		}
		userPairs.append(("bodyData", .object(user.bodyData.keys.sorted().map { name in
			(name, .object([("value", .int(user.bodyData[name]!)), ("predicted", .bool(true))]))
		})))

		return .object([
			("product", .object(productPairs)),
			("user", .object(userPairs)),
			("ext_product_id", .string(extProductId))
		])
	}

	/// The payload serialized as JSON, with the object keys in the web widget's order
	func jsonData() -> Data? {
		return jsonValue.serialized.data(using: .utf8)
	}
}
