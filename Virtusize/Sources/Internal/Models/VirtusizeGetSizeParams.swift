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

// swiftlint:disable line_length
/// The structure that wraps the parameters for the API request to get the recommended size based on a user's body profile
internal struct VirtusizeGetSizeParams: Codable {
    /// The store product additional info
   // var additionalInfo: [String: VirtusizeAnyCodable] = [:]
    /// The user body data
    var bodyData: [String: [String: VirtusizeAnyCodable]] = [:]
    /// The store product size info
  //  var itemSizesOrig: [String: [String: Int?]] = [:]
    /// The store product type
  //  var productType: String = ""
    /// The user's gender
    var userGender: String = ""
    /// The user's height
    var userHeight: Int?
    /// The user's weight
    var userWeight: Float?
    /// The external product ID provided by the client
   // var extProductId: String = ""
    
    var items : [VirtusizeGetSizeItemsParam]
    
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
        
   ///Chirag : Commented modelInfo not getting proper value  but its optional
   ///Chirag: Gender value geting from userBodyProfile, not geeting from storeProduct.storeProductMeta?.additionalInfo
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
//            "modelInfo": VirtusizeAnyCodable(
//                getModelInfoDict(storeProduct: storeProduct)
//            ),
//            "gender": VirtusizeAnyCodable(
//                storeProduct.storeProductMeta?.additionalInfo?.gender ?? storeProduct.storeProductMeta?.gender ?? nil
//            )
            
            "gender": VirtusizeAnyCodable(
                userBodyProfile?.gender ?? nil
            )
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
       //let extProductId = storeProduct.externalId
        
        items = [VirtusizeGetSizeItemsParam(additionalInfo: additionalInfo,itemSizesOrig: itemSizesOrig,productType: productType, extProductId: storeProduct.externalId)]
        
        
    }
}

	/// Gets the dictionary of the model info
	private func getModelInfoDict(storeProduct: VirtusizeServerProduct) -> [String: Any] {
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

	/// Gets the dictionary of the user body data
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

	/// Gets the dictionary of the store product size info
	private func getItemSizesDict(storeProduct: VirtusizeServerProduct) -> [String: [String: Int?]] {
		var itemSizesDict: [String: [String: Int?]] = [:]
		for productSize in storeProduct.sizes {
			itemSizesDict[productSize.name ?? ""] = productSize.measurements
		}
		return itemSizesDict
	}
    

