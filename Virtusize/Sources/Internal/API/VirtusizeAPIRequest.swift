//
//  VirtusizeAPIRequest.swift
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

extension APIRequest {
	/// Gets the `URLRequest` for the `productCheck` request
	///
	/// - Parameter product: `VirtusizeProduct` for which check needs to be performed
	/// - Returns: A `URLRequest` for the `productCheck` request
	internal static func productCheck(product: VirtusizeProduct) -> URLRequest {
		let endpoint = APIEndpoints.productCheck(externalId: product.externalId)
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `productMetaDataHints` request to send the image of
	/// VirtusizeProduct to the Virtusize server
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` for which check needs to be performed
	///   - storeId: An integer that represents the store id from the product data
	/// - Returns: A `URLRequest` for the `productMetaDataHints` request
	internal static func sendProductImage(of product: VirtusizeProduct, forStore storeId: Int) throws -> URLRequest? {
		guard let imageURL = product.imageURL else {
			fatalError("Image url is not defined")
		}

		let endpoint = APIEndpoints.productMetaDataHints
		let productImageMetaData = VirtusizeProductMetaData(
			storeId: storeId,
			externalId: product.externalId,
			imageUrl: imageURL.absoluteString,
			apiKey: endpoint.apiKey
		)
		guard let jsonData = try? JSONEncoder().encode(productImageMetaData) else {
			return nil
		}
		return apiRequest(components: endpoint.components, withPayload: jsonData)
	}

	/// Gets the `URLRequest` for the `sendEvent` request
	///
	/// - Parameters:
	///   - virtusizeEvent: An event to be sent to the Virtusize server
	///   - context: The product data from the response of the `productCheck` request
	/// - Returns: A `URLRequest` for the `sendEvent` request
	internal static func sendEvent(
		_ virtusizeEvent: VirtusizeEvent, withContext context: JSONObject?) -> URLRequest? {
		let endpoint = APIEndpoints.events

		var event = APIEvent(withName: virtusizeEvent.name, apiKey: endpoint.apiKey)
		event.align(withContext: context)
		event.align(withPayload: virtusizeEvent.data as? [String: Any])

		guard let payloadData = event.jsonPayload else {
			return nil
		}
		return apiRequest(components: endpoint.components, withPayload: payloadData)
	}

    /// Gets the `URLRequest` for the `latestAoyamaVersion` request
    ///
    /// - Returns: A `URLRequest` for the `latestAoyamaVersion` request
    internal static func fetchLatestAoyamaVersion() -> URLRequest {
        let endpoint = APIEndpoints.latestAoyamaVersion
        return apiRequest(components: endpoint.components)
    }

	/// Gets the `URLRequest` for the `VirtusizeWebView` request
    /// - Parameters:
    ///   - version: The version of Aoyama
	/// - Returns: A `URLRequest` for the `VirtusizeWebView` request
    internal static func virtusizeWebView(version: String) -> URLRequest {
        let endpoint = APIEndpoints.virtusizeWebView(version: version)
		return HTTPRequest(components: endpoint.components)
	}

    /// Gets the `URLRequest` for the `VirtusizeWebView` request for specific clients
    ///
    /// - Returns: A `URLRequest` for the `VirtusizeWebView` request
    internal static func virtusizeWebViewForSpecificClients() -> URLRequest {
        let endpoint = APIEndpoints.virtusizeWebViewForSpecificClients
        return HTTPRequest(components: endpoint.components)
    }

	/// Gets the `URLRequest` for the `storeViewApiKey` request
	///
	/// - Returns: A `URLRequest` for the `storeViewApiKey` request
	internal static func retrieveStoreInfo() -> URLRequest? {
		let endpoint = APIEndpoints.storeViewApiKey
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `orders` request
	///
	/// - Parameter order: A `VirtusizeOrder` that includes the info of the order and the items that the user purchased
	/// - Returns: A `URLRequest` for the `orders` request
	internal static func sendOrder(_ order: VirtusizeOrder) -> URLRequest? {
		let endpoint = APIEndpoints.orders
		guard let jsonData = try? JSONEncoder().encode(order) else {
			return nil
		}
		return apiRequest(components: endpoint.components, withPayload: jsonData)
	}

	/// Gets the `URLRequest` for the `storeProducts` request
	///
	/// - Parameter productId: The ID of the product
	/// - Returns: A `URLRequest` for the `storeProducts` request
	internal static func getStoreProductInfo(productId: Int) -> URLRequest? {
		let endpoint = APIEndpoints.storeProducts(productId: productId)
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `productTypes` request
	///
	/// - Returns: A `URLRequest` for the `productTypes` request
	internal static func getProductTypes() -> URLRequest? {
		let endpoint = APIEndpoints.productTypes
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `sessions` request
	///
	/// - Returns: A `URLRequest` for the `sessions` request
	internal static func getSessions() -> URLRequest? {
		let endpoint = APIEndpoints.sessions
		return apiRequestWithAuthHeader(components: endpoint.components)
	}

	internal static func deleteUserData() -> URLRequest? {
		let endpoint = APIEndpoints.user
		return apiRequestWithAuthHeader(components: endpoint.components, method: .delete)
	}

	/// Gets the `URLRequest` for the `storeProducts` request
	///
	/// - Parameter productId: The ID of the product
	/// - Returns: A `URLRequest` for the `storeProducts` request
	internal static func getUserProducts() -> URLRequest? {
		let endpoint = APIEndpoints.userProducts
		return apiRequestWithAuthorization(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `userBodyMeasurements` request
	///
	/// - Returns: A `URLRequest` for the `userBodyMeasurements` request
	internal static func getUserBodyProfile() -> URLRequest? {
		let endpoint = APIEndpoints.userBodyMeasurements
		return apiRequestWithAuthorization(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the `getSize` request
	///
	/// - Parameters:
	///   - productTypes: The list of available `ProductType`s
	///   - storeProduct: The store product info whose data type is `VirtusizeServerProduct`
	///   - userBodyProfile: The user body profile whose data type is  `VirtusizeUserBodyProfile`
	/// - Returns: A `URLRequest` for the `getSize` request
	internal static func getBodyProfileRecommendedSize(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) -> URLRequest? {
		let endpoint = APIEndpoints.getSize
		guard let jsonData = try? JSONEncoder().encode(
			VirtusizeGetSizeParams(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile
			)
		) else {
			return nil
		}
		return apiRequest(components: endpoint.components, withPayload: jsonData)
	}

	/// Gets the `URLRequest` for the request to get i18n texts
	///
	/// - Parameter langCode: The language code to get the texts in a specific language
	/// - Returns: A `URLRequest` for the request to get i18n texts
	internal static func getI18n(langCode: String) -> URLRequest? {
		let endpoint = APIEndpoints.i18n(langCode: langCode)
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the request to get store specific i18n texts
	///
	/// - Parameter storeName: The store name
	/// - Returns: A `URLRequest` for the request to get i18n texts
	internal static func getStoreI18n(storeName: String) -> URLRequest? {
		let endpoint = APIEndpoints.storeI18n(storeName: storeName)
		return apiRequest(components: endpoint.components)
	}

	/// Gets the `URLRequest` for the request to load an image via a URL
	///
	/// - Parameter url: The URL of the image
	/// - Returns: A `URLRequest` for the request to load an image
	internal static func loadImage(url: URL) -> URLRequest? {
		var components = URLComponents()
		components.scheme = "https"
		components.host = url.host
		return HTTPRequest(components: components)
	}
}
