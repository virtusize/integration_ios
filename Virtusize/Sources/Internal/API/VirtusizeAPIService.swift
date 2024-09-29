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
	internal static func productCheckAsync(product: VirtusizeProduct) -> APIResult<VirtusizeProduct> {
		let request = APIRequest.productCheck(product: product)
		return getAPIResultAsync(request: request, type: VirtusizeProduct.self)
	}

	/// The API request for sending image of VirtusizeProduct to the Virtusize server
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` whose image needs to be sent to the Virtusize server
	///   - storeId: An integer that represents the store id from the product data
	///   - completion: A callback to pass the value of `JSONObject` back when the request is successful
	internal static func sendProductImage(
		of product: VirtusizeProduct,
		forStore storeId: Int,
		completion completionHandler: ((JSONObject?) -> Void)? = nil
	) {
		guard let request = try? APIRequest.sendProductImage(of: product, forStore: storeId) else {
			return
		}
		VirtusizeAPIService.perform(request, completion: { data in
			guard let data = data else {
				return
			}
			let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
			completionHandler?(jsonObject)
		})
	}

	/// The API request for logging an event and sending it to the Virtusize server
	///
	/// - Parameters:
	///   - event: An event to be sent to the Virtusize server
	///   - context: The product data from the response of the `productDataCheck` request
	///   - completionHandler: A callback to pass `JSONObject` back when an API request is successful
	internal static func sendEvent(
		_ event: VirtusizeEvent,
		withContext context: JSONObject? = nil,
		completion completionHandler: ((JSONObject?) -> Void)? = nil
	) {
		guard let request = APIRequest.sendEvent(event, withContext: context) else {
			return
		}
		VirtusizeAPIService.perform(request, completion: { data in
			guard let data = data else {
				return
			}
			let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
			completionHandler?(jsonObject)
		})
	}

	/// The API request for retrieving the specific store info from the API key
	/// that is unique to the client
	///
	/// - Returns: the store data in the type of `VirtusizeStore`
	internal static func retrieveStoreInfoAsync() -> APIResult<VirtusizeStore> {
		guard let request = APIRequest.retrieveStoreInfo() else {
			return .failure()
		}
		return getAPIResultAsync(request: request, type: VirtusizeStore.self)
	}

	/// The API request for sending an order to the Virtusize server
	/// - Parameters:
	///   - order: An order in `VirtusizeOrder` type
	/// - Returns: the order info in the type of `String`
	internal static func sendOrderWithRegionAsync(_ order: VirtusizeOrder) -> APIResult<String> {
		guard let request = APIRequest.sendOrder(order) else {
			return .failure()
		}
		return getAPIResultAsync(request: request, type: String.self)
	}

	/// The API request for getting the store product info from the Virtusize server
	///
	/// - Parameters:
	///   - productId: The internal product ID from the Virtusize server
	/// - Returns: the store product info in the type of `VirtusizeServerProduct`
	internal static func getStoreProductInfoAsync(productId: Int) -> APIResult<VirtusizeServerProduct> {
		guard let request = APIRequest.getStoreProductInfo(productId: productId) else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: VirtusizeServerProduct.self)
	}

	/// The API request for getting the list of all the product types from the Virtusize server
	///
	/// - Returns: the product type list where its each element is in the type of `VirtusizeProductType`
	internal static func getProductTypesAsync() -> APIResult<[VirtusizeProductType]> {
		guard let request = APIRequest.getProductTypes() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: [VirtusizeProductType].self)
	}

	/// The API request for getting the user session data from the Virtusize server
	///
	/// - Returns: the user session data in the type of `UserSessionInfo`
	internal static func getUserSessionInfoAsync() -> APIResult<UserSessionInfo> {
		guard let request = APIRequest.getSessions() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: UserSessionInfo.self)
	}

	internal static func deleteUserDataAsync() -> APIResult<String> {
		guard let request = APIRequest.deleteUserData() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: nil)
	}

	/// The API request for getting the list of user products from the Virtusize server
	///
	/// - Returns: the user product data in the type of `VirtusizeServerProduct`
	internal static func getUserProductsAsync() -> APIResult<[VirtusizeServerProduct]> {
		guard let request = APIRequest.getUserProducts() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: [VirtusizeServerProduct].self)
	}

	/// The API request for getting the user body profile data from the Virtusize server
	///
	/// - Returns: the user body profile data in the type of `VirtusizeUserBodyProfile`
	internal static func getUserBodyProfileAsync() -> APIResult<VirtusizeUserBodyProfile> {
		guard let request = APIRequest.getUserBodyProfile() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: VirtusizeUserBodyProfile.self)
	}

	/// The API request for retrieving the recommended sizes based on the user body profile
	///
	/// - Parameters:
	///   - productTypes: A list of product types
	///   - storeProduct: The store product data
	///   - userBodyProfile: the user body profile data
	/// - Returns: the user body profile recommended size array in the type of `BodyProfileRecommendedSize`
	internal static func getBodyProfileRecommendedSizesAsync(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) -> APIResult<BodyProfileRecommendedSizeArray> {
		guard let request = APIRequest.getBodyProfileRecommendedSize(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile)
        else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: BodyProfileRecommendedSizeArray.self)
	}

	/// The API request for getting i18 localization texts
	///
	/// - Returns: the i18 localization texts in the type of `VirtusizeI18nLocalization`
	internal static func getI18nTextsAsync() -> APIResult<VirtusizeI18nLocalization> {
		guard let virtusizeParams = Virtusize.params,
			  let request = APIRequest.getI18n(
				langCode: virtusizeParams.language.rawValue
			  ) else {
			return .failure(nil)
		}

		let apiResponse = VirtusizeAPIService.performAsync(request)

		guard apiResponse?.virtusizeError == nil,
			  let data = apiResponse?.data else {
			return .failure(apiResponse?.code, apiResponse?.virtusizeError)
		}

		return .success(Deserializer.i18n(data: data))
	}

	// The API request for loading an image from a URL
	///
	/// - Parameters:
	///   - url: The image of the URL
	/// - Returns: the loaded image in the type of `UIImage`
	internal static func loadImageAsync(url: URL?) -> APIResult<UIImage> {
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
    internal static func fetchLatestAoyamaVersion() -> APIResult<String> {
        let request = APIRequest.fetchLatestAoyamaVersion()
        let apiResponse = VirtusizeAPIService.performAsync(request)
        guard let data = apiResponse?.data,
              let version = String(data: data, encoding: .utf8) else {
            return .failure(apiResponse?.code, apiResponse?.virtusizeError)
        }
        let trimmedVersion = version.trimmingCharacters(in: .whitespacesAndNewlines)
        return .success(trimmedVersion, nil)
    }
}
