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

internal struct VirtusizeGetSizeParams: Codable {
    var additionalInfo: [String: VirtusizeAnyCodable] = [:]
    var bodyData: [String: [String: VirtusizeAnyCodable]] = [:]
    var itemSizes: [String: [String: Int?]] = [:]
    var productType: String = ""
    var userGender: String = ""

    private enum CodingKeys: String, CodingKey {
        case additionalInfo = "additional_info"
        case bodyData = "body_data"
        case itemSizes = "item_sizes_orig"
        case productType = "product_type"
        case userGender = "user_gender"
    }

    init(productTypes: [VirtusizeProductType],
         storeProduct: VirtusizeInternalProduct,
         userBodyProfile: VirtusizeUserBodyProfile?
    ) {
        additionalInfo = [
            "brand": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.brand ?? storeProduct.storeProductMeta?.brand ?? ""
            ),
            "fit": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.fit ?? "regular"
            ),
            "sizes": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.sizes ?? [:]
            ),
            "model_info": VirtusizeAnyCodable(
                getModelInfoDict(storeProduct: storeProduct)
            ),
            "gender": VirtusizeAnyCodable(
                storeProduct.storeProductMeta?.additionalInfo?.gender ?? storeProduct.storeProductMeta?.gender ?? nil
            )
        ]
        bodyData = getBodyDataDict(userBodyProfile: userBodyProfile)
        itemSizes = getItemSizesDict(storeProduct: storeProduct)
        if let index = productTypes.firstIndex(where: { $0.id == storeProduct.productType }) {
            productType = productTypes[index].name
        }
        userGender = userBodyProfile?.gender ?? ""
    }

    private func getModelInfoDict(storeProduct: VirtusizeInternalProduct) -> [String: Any] {
        var modelInfoDict: [String: Any] = [:]
        if let modelInfo = storeProduct.storeProductMeta?.additionalInfo?.modelInfo {
            for (name, measurement) in modelInfo {
                if let measurement = measurement.value as? Int {
                    modelInfoDict[name] = measurement as Int
                } else if let measurement = measurement.value as? String {
                    modelInfoDict[name] = measurement as String
                }
            }
        }
        return modelInfoDict
    }

    private func getBodyDataDict(
        userBodyProfile: VirtusizeUserBodyProfile?
    ) -> [String: [String: VirtusizeAnyCodable]] {
        var bodyDataDict: [String: [String: VirtusizeAnyCodable]] = [:]
        if let bodyData = userBodyProfile?.bodyData {
            for (name, measurement) in bodyData {
                if let measurement = measurement {
                    bodyDataDict[name] = [
                        "value": VirtusizeAnyCodable(measurement),
                        "predicted": VirtusizeAnyCodable(true)
                    ]
                    if name == "bust" {
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

    private func getItemSizesDict(storeProduct: VirtusizeInternalProduct) -> [String: [String: Int?]] {
        var itemSizesDict: [String: [String: Int?]] = [:]
        for productSize in storeProduct.sizes {
            itemSizesDict[productSize.name ?? ""] = productSize.measurements
        }
        return itemSizesDict
    }
}
