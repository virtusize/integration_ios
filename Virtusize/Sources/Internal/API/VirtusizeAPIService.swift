//
//  VirtusizeAPIService.swift
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

import UIKit
import Foundation
import VirtusizeCore

/// This class is to handle API requests to the Virtusize server
class VirtusizeAPIService: APIService {
	/// The API request for product check
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` for which check needs to be performed
	/// - Returns: the product check data in the type of `VirtusizeProduct`
	internal static func productCheckAsync(product: VirtusizeProduct) async -> APIResult<VirtusizeProduct> {
		let request = APIRequest.productCheck(product: product)
		let result = await getAPIResultAsync(request: request, type: VirtusizeProduct.self)
        APICache.shared.currentStoreId = result.success?.productCheckData?.storeId
        return result
	}

	/// The API request for sending image of VirtusizeProduct to the Virtusize server
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` whose image needs to be sent to the Virtusize server
	///   - storeId: An integer that represents the store id from the product data
	/// - Returns: `JSONObject` for successful reponse, otherwise nil
	internal static func sendProductImage(
		of product: VirtusizeProduct,
		forStore storeId: Int
	) async -> JSONObject? {
		guard let request = try? APIRequest.sendProductImage(of: product, forStore: storeId) else {
			return nil
		}

		let response = await VirtusizeAPIService.performAsync(request)
		guard response.virtusizeError == nil, let data = response.data else {
			// failed to perform request
			return nil
		}
		return try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
	}

	/// The API request for logging an event and sending it to the Virtusize server
	///
	/// - Parameters:
	///   - event: An event to be sent to the Virtusize server
	///   - context: The product data from the response of the `productCheck` request
	/// - Returns: `JSONObject` for successful reponse, otherwise nil
	internal static func sendEvent(
		_ event: VirtusizeEvent,
		withContext context: JSONObject? = nil
	) async -> JSONObject? {
		guard let request = APIRequest.sendEvent(event, withContext: context) else {
			return nil
		}

		let response = await VirtusizeAPIService.performAsync(request)
		guard response.virtusizeError == nil, let data = response.data else {
			// failed to perform request
			return nil
		}
		return try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
	}

	/// The API request for retrieving the specific store info from the API key
	/// that is unique to the client
	///
	/// - Returns: the store data in the type of `VirtusizeStore`
	internal static func retrieveStoreInfoAsync() async -> APIResult<VirtusizeStore> {
		guard let request = APIRequest.retrieveStoreInfo() else {
			return .failure()
		}
		return await getAPIResultAsync(request: request, type: VirtusizeStore.self)
	}

	/// The API request for sending an order to the Virtusize server
	/// - Parameters:
	///   - order: An order in `VirtusizeOrder` type
	/// - Returns: the order info in the type of `String`
	internal static func sendOrderWithRegionAsync(_ order: VirtusizeOrder) async -> APIResult<String> {
		guard let request = APIRequest.sendOrder(order) else {
			return .failure()
		}
		return await getAPIResultAsync(request: request, type: String.self)
	}

	/// The API request for getting the store product info from the Virtusize server
	///
	/// - Parameters:
	///   - productId: The internal product ID from the Virtusize server
	/// - Returns: the store product info in the type of `VirtusizeServerProduct`
	internal static func getStoreProductInfoAsync(productId: Int) async -> APIResult<VirtusizeServerProduct> {
		guard let request = APIRequest.getStoreProductInfo(productId: productId) else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: VirtusizeServerProduct.self)
	}

	/// The API request for getting the list of all the product types from the Virtusize server
	///
	/// - Returns: the product type list where its each element is in the type of `VirtusizeProductType`
	internal static func getProductTypesAsync() async -> APIResult<[VirtusizeProductType]> {
		guard let request = APIRequest.getProductTypes() else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: [VirtusizeProductType].self)
	}

	/// The API request for getting the user session data from the Virtusize server
	///
	/// - Returns: the user session data in the type of `UserSessionInfo`
	internal static func getUserSessionInfoAsync() async -> APIResult<UserSessionInfo> {
		guard let request = APIRequest.getSessions() else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: UserSessionInfo.self)
	}

	internal static func deleteUserDataAsync() async -> APIResult<String> {
		guard let request = APIRequest.deleteUserData() else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: nil)
	}

	/// The API request for getting the list of user products from the Virtusize server
	///
	/// - Returns: the user product data in the type of `VirtusizeServerProduct`
	internal static func getUserProductsAsync() async -> APIResult<[VirtusizeServerProduct]> {
		guard let request = APIRequest.getUserProducts() else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: [VirtusizeServerProduct].self)
	}

	/// The API request for getting the user body profile data from the Virtusize server
	///
	/// - Returns: the user body profile data in the type of `VirtusizeUserBodyProfile`
	internal static func getUserBodyProfileAsync() async -> APIResult<VirtusizeUserBodyProfile> {
		guard let request = APIRequest.getUserBodyProfile() else {
			return .failure(nil)
		}
		return await getAPIResultAsync(request: request, type: VirtusizeUserBodyProfile.self)
	}

	/// The API request for retrieving the recommended item sizes based on the user body profile
	///
	/// - Parameters:
	///   - productTypes: A list of product types
	///   - storeProduct: The store product data
	///   - userBodyProfile: the user body profile data
	/// - Returns: the user body profile recommended item size array in the type of `BodyProfileRecommendedSize`
	internal static func getBodyProfileRecommendedItemSizesAsync(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) async -> APIResult<BodyProfileRecommendedSizeArray> {
		guard let request = APIRequest.getBodyProfileRecommendedSize(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile)
        else {
			return .failure(nil)
		}

		return await getAPIResultAsync(request: request, type: BodyProfileRecommendedSizeArray.self)
	}

	/// The API request for retrieving the recommended shoe size based on the user body profile
	///
	/// - Parameters:
	///   - productTypes: A list of product types
	///   - storeProduct: The store product data
	///   - userBodyProfile: the user body profile data
	/// - Returns: the user body profile recommended shoe size in the type of `BodyProfileRecommendedSize`
	internal static func getBodyProfileRecommendedShoeSizeAsync(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) async -> APIResult<BodyProfileRecommendedSize> {
		guard let request = APIRequest.getBodyProfileRecommendedShoeSize(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile)
        else {
			return .failure(nil)
		}

		return await getAPIResultAsync(request: request, type: BodyProfileRecommendedSize.self)
	}

	/// The API request for getting i18n localization texts
	///
	/// - Returns: the i18 localization texts as JSON object
	internal static func getI18nAsync(language: VirtusizeLanguage? = nil) async -> APIResult<JSONObject> {
		guard let lang = language ?? Virtusize.params?.language,
			  let request = APIRequest.getI18n(
				langCode: lang.rawValue
			  ) else {
			return .failure(nil)
		}

		let apiResponse = await VirtusizeAPIService.performAsync(request)

		guard apiResponse.virtusizeError == nil,
			  let data = apiResponse.data else {
			return .failure(apiResponse.code, apiResponse.virtusizeError)
		}

		let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
		return .success(json)
	}

	/// The API request for getting store specific i18n localization texts
	///
	/// - Returns: the i18 localization texts as JSON object
	internal static func getStoreI18nAsync(storeName: String) async -> APIResult<JSONObject> {
		guard let request = APIRequest.getStoreI18n(storeName: storeName) else {
			return .failure(nil)
		}

		let apiResponse = await VirtusizeAPIService.performAsync(request)

		guard apiResponse.virtusizeError == nil,
			  let data = apiResponse.data else {
			return .failure(apiResponse.code, apiResponse.virtusizeError)
		}

		let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
		return .success(json)
	}

	// The API request for loading an image from a URL
	///
	/// - Parameters:
	///   - url: The image of the URL
	/// - Returns: the loaded image in the type of `UIImage`
	internal static func loadImageSync(url: URL?) -> APIResult<UIImage> {
		guard url != nil, let data = try? Data(contentsOf: url!),
			  let image = UIImage(data: data)
		else {
			return .failure(nil, VirtusizeError.failToLoadImage(url))
		}
		return .success(image, nil)
	}

    // The API request for fetching the latest version of Aoyama from a txt URL
    ///
    /// - Returns: the version in `String`
    internal static func fetchLatestAoyamaVersion() async -> APIResult<String> {
        let request = APIRequest.fetchLatestAoyamaVersion()
        let apiResponse = await VirtusizeAPIService.performAsync(request)
        guard let data = apiResponse.data,
              let version = String(data: data, encoding: .utf8) else {
            return .failure(apiResponse.code, apiResponse.virtusizeError)
        }
        let trimmedVersion = version.trimmingCharacters(in: .whitespacesAndNewlines)
        return .success(trimmedVersion, nil)
    }
}
