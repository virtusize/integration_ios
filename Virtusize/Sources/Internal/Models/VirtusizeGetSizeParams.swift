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
    /// The user's weight as a number, matching the web widget (`57`, not `"57.00"`)
    var userWeight: Double?
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
       var additionalInfo: [String: VirtusizeAnyCodable] = [
            "brand": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.brand ?? storeProduct.storeProductMeta?.brand ?? ""
            ),
            "fit": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.fit ?? "regular"
            ),
            "sizes": VirtusizeAnyCodable(
                snakeCaseSizeMeasurements(storeProduct.storeProductMeta?.additionalInfo?.sizes ?? [:])
            ),
            "gender": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.gender ?? "male"
            ),
            "style": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.style ?? "regular"
            )
        ]
        
        if let modelInfo = getModelInfoDict(storeProduct: storeProduct) {
            additionalInfo["modelInfo"] = VirtusizeAnyCodable(modelInfo)
        }
        bodyData = getBodyDataDict(userBodyProfile: userBodyProfile)
        let itemSizesOrig = getItemSizesDict(storeProduct: storeProduct)
        // The web widget sends these keys; the encoder does not touch dictionary keys,
        // so they must be snake_case literals here
        additionalInfo["item_measurements"] = VirtusizeAnyCodable(!itemSizesOrig.isEmpty)
        // Without this order the API walks `item_sizes_orig` in dictionary order and can return a different size
        let sizeOrder: [Any?] = storeProduct.sizes
            .compactMap { $0.name }
            .filter { !$0.isEmpty }
            .sortedLikeJavaScriptObjectKeys()
            .map { $0 as Any? }
        additionalInfo["client_size_order"] = VirtusizeAnyCodable(sizeOrder)
        var productType = ""
        if let index = productTypes.firstIndex(where: { $0.id == storeProduct.productType }) {
            // The API returns camelCase names (e.g. "tShirt") while the web widget sends "t_shirt"
            productType = camelCaseToSnakeCase(productTypes[index].name)
        }
        userGender = userBodyProfile?.gender ?? ""
        userHeight = userBodyProfile?.height
        userWeight = userBodyProfile?.weight.flatMap(Double.init)
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
internal func getBodyDataDict(
	userBodyProfile: VirtusizeUserBodyProfile?
) -> [String: [String: VirtusizeAnyCodable]] {
	var bodyDataDict: [String: [String: VirtusizeAnyCodable]] = [:]
	if let bodyData = userBodyProfile?.bodyData {
		for (name, measurement) in bodyData {
            let snakeKey = camelCaseToSnakeCase(name)
			if let measurement = measurement {
				bodyDataDict[snakeKey] = measurementEntry(aoyamaMillimeters(measurement, key: snakeKey))
				if snakeKey == "bust" {
					// Aoyama stores chest as the rounded bust and leaves bust itself unrounded
					bodyDataDict["chest"] = measurementEntry(aoyamaMillimeters(measurement, key: "chest"))
				}
			}
		}
	}

    if let braSize = userBodyProfile?.braSize {
        for (name, anyCodable) in braSize {
            let snakeKey = camelCaseToSnakeCase(name)
            if let anyCodable = anyCodable {
                if snakeKey == "band" {
                    if let bandValue = anyCodable.value as? Int {
                        bodyDataDict["bra_\(snakeKey)"] = measurementEntry(bandValue * 10, predicted: false)
                    }
                } else {
                    bodyDataDict["bra_\(snakeKey)"] = [
                        "value": anyCodable,
                        "predicted": VirtusizeAnyCodable(false)
                    ]
                }
            }
        }
    }
	if userBodyProfile != nil {
		// Aoyama always sends these, including when the profile has no bra size
		if bodyDataDict["bra_country"] == nil {
			bodyDataDict["bra_country"] = measurementEntry("", predicted: false)
		}
		if bodyDataDict["bra_cup"] == nil {
			bodyDataDict["bra_cup"] = measurementEntry("", predicted: false)
		}
		if bodyDataDict["bra_band"] == nil {
			bodyDataDict["bra_band"] = measurementEntry(0, predicted: false)
		}
	}
	return bodyDataDict
}

/// Aoyama `parseBodyMeasurements` divides every measurement by 10. These names are also
/// `Math.round`ed, which is nearest 10 mm. Every other measurement, including ones the
/// profile JSON adds later, is sent unchanged.
private let aoyamaRoundedBodyMeasurements: Set<String> = [
	"shoulder", "bicep", "chest", "waist", "hip", "thigh", "inseam"
]

private func aoyamaMillimeters(_ millimeters: Int, key: String) -> Int {
	guard aoyamaRoundedBodyMeasurements.contains(key) else { return millimeters }
	return (millimeters + 5) / 10 * 10
}

private func measurementEntry(_ value: Any, predicted: Bool = true) -> [String: VirtusizeAnyCodable] {
	[
		"value": VirtusizeAnyCodable(value),
		"predicted": VirtusizeAnyCodable(predicted)
	]
}

/// `additionalInfo.sizes` arrives with camelCase measurement names (`frontRise`).
/// The web widget sends those names in snake_case (`front_rise`).
/// Returned as `[String: Any?]` so `VirtusizeAnyCodable` encodes the nested maps.
private func snakeCaseSizeMeasurements(
	_ sizes: [String: [String: Int?]]
) -> [String: Any?] {
	var result: [String: Any?] = [:]
	for (sizeName, measurements) in sizes {
		var measurementPayload: [String: Any?] = [:]
		for (key, value) in measurements {
			measurementPayload[camelCaseToSnakeCase(key)] = value
		}
		result[sizeName] = measurementPayload
	}
	return result
}

/// Gets the dictionary of the store product size info
/// Measurement names arrive camelCase from the store-products API (e.g. "bustRound"),
/// but the get-size API expects the web widget's snake_case names ("bust_round")
internal func getItemSizesDict(storeProduct: VirtusizeServerProduct) -> [String: [String: Int?]] {
	var itemSizesDict: [String: [String: Int?]] = [:]
	for productSize in storeProduct.sizes {
		itemSizesDict[productSize.name ?? ""] = Dictionary(
			productSize.measurements.map { (camelCaseToSnakeCase($0.key), $0.value) },
			uniquingKeysWith: { first, _ in first }
		)
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
