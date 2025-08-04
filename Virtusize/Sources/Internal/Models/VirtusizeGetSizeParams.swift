//
//  VirtusizeGetSizeParams.swift
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

import Foundation

// swiftlint:disable:next line_length
/// The structure that wraps the parameters for the API request to get the recommended size based on a user's body profile
internal struct VirtusizeGetSizeParams: Codable {
    var appOrigin: Int = 2
    /// The user body data
    var bodyData: [String: [String: VirtusizeAnyCodable]] = [:]
    /// The user's gender
    var userGender: String = ""
    /// The user's height
    var userHeight: Int?
    /// The user's weight
    var userWeight: Float?
    /// The user's age
    var userAge: Int?
    /// The user's items
    var items: [VirtusizeGetSizeItemsParam]

    /// Initializes the VirtusizeGetSizeParams structure
    ///
    /// - Parameters:
    ///   - productTypes: The list of available `VirtusizeProductType`
    ///   - storeProduct: The store product info in the type of `VirtusizeInternalProduct`
    ///   - userBodyProfile: The user body profile
    init(
        productTypes: [VirtusizeProductType],
        storeProduct: VirtusizeServerProduct,
        userBodyProfile: VirtusizeUserBodyProfile?

    ) {
       let additionalInfo = [
            "brand": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.brand ?? storeProduct.storeProductMeta?.brand ?? ""
            ),
            "fit": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.fit ?? "regular"
            ),
            "sizes": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.sizes ?? [:]
            ),
            "modelInfo": VirtusizeAnyCodable(getModelInfoDict(storeProduct: storeProduct)),
            "gender": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.gender ?? "male"
            ),
            "style": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.style ?? "regular"
            ),
        ]
        bodyData = getBodyDataDict(userBodyProfile: userBodyProfile)
        let itemSizesOrig = getItemSizesDict(storeProduct: storeProduct)
        var productType = ""
        if let index = productTypes.firstIndex(where: { $0.id == storeProduct.productType }) {
            productType = productTypes[index].name
        }
        userGender = userBodyProfile?.gender ?? ""
        userHeight = userBodyProfile?.height
        if let weight = userBodyProfile?.weight {
            userWeight = Float(weight)
        }
        userAge = userBodyProfile?.age

        items = [
            VirtusizeGetSizeItemsParam(
                additionalInfo: additionalInfo,
                itemSizesOrig: itemSizesOrig,
                productType: productType,
                extProductId: storeProduct.externalId
            )
        ]

    }
}

// -- Helper functions

/// Gets the dictionary of the model info
private func getModelInfoDict(storeProduct: VirtusizeServerProduct) -> [String: Any]? {
	var modelInfoDict: [String: Any] = [:]
	if let modelInfo = storeProduct.storeProductMeta?.additionalInfo?.modelInfo {
		for (name, measurement) in modelInfo {
            let snakeKey = camelCaseToSnakeCase(name)
			if let measurement = measurement.value as? Int {
				modelInfoDict[snakeKey] = measurement as Int
			} else if let measurement = measurement.value as? String {
				modelInfoDict[snakeKey] = measurement as String
			}
		}
	}
	return modelInfoDict.isEmpty ? nil : modelInfoDict
}

/// Gets the dictionary of the user body data
private func getBodyDataDict(
	userBodyProfile: VirtusizeUserBodyProfile?
) -> [String: [String: VirtusizeAnyCodable]] {
	var bodyDataDict: [String: [String: VirtusizeAnyCodable]] = [:]
	if let bodyData = userBodyProfile?.bodyData {
		for (name, measurement) in bodyData {
            let snakeKey = camelCaseToSnakeCase(name)
			if let measurement = measurement {
				bodyDataDict[snakeKey] = [
					"value": VirtusizeAnyCodable(measurement),
					"predicted": VirtusizeAnyCodable(true)
				]
				if snakeKey == "bust" {
					bodyDataDict["chest"] = [
						"value": VirtusizeAnyCodable(measurement),
						"predicted": VirtusizeAnyCodable(true)
					]
				}
			}
		}
	}
	return bodyDataDict
}

/// Gets the dictionary of the store product size info
private func getItemSizesDict(storeProduct: VirtusizeServerProduct) -> [String: [String: Int?]] {
	var itemSizesDict: [String: [String: Int?]] = [:]
	for productSize in storeProduct.sizes {
		itemSizesDict[productSize.name ?? ""] = productSize.measurements
	}
	return itemSizesDict
}

private func camelCaseToSnakeCase(_ string: String) -> String {
    let pattern = "([a-z0-9])([A-Z])"
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: string.count)
    let snake = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "$1_$2") ?? string
    return snake.lowercased()
}
