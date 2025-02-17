//
//  VirtusizeRepository.swift
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

/// This class is used to handle the logic required to access remote and local data sources
internal class VirtusizeRepository: NSObject {

	static let shared = VirtusizeRepository()

	/// The session API response as a string
	var userSessionResponse: String = ""
	/// The array of `VirtusizeView` that clients use on their mobile application
	var productTypes: [VirtusizeProductType]?
	// This variable holds the i18n localization texts
	var i18nLocalization: VirtusizeI18nLocalization?
	/// The last visited store product on the Virtusize webview
	var lastProductOnVirtusizeWebView: VirtusizeServerProduct?

	private var userProducts: [VirtusizeServerProduct]?
	private var userBodyProfile: VirtusizeUserBodyProfile?
	private var sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?
    private var bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	private var hasSessionBodyMeasurement: Bool = false

	/// A set to cache the store product information of all the visited products
	private var serverStoreProductSet: Set<VirtusizeServerProduct> = []

	/// Checks if the product in `VirtusizeProduct` is valid and post notifications
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct`
	/// - Returns: a valid`VirtusizeProduct` with the PDC data or nil if check failed
	internal func checkProductValidity(product: VirtusizeProduct) async -> VirtusizeProduct? {
		let productResponse = await VirtusizeAPIService.productCheckAsync(product: product)
		guard let product = productResponse.success else {
			NotificationCenter.default.post(
				name: Virtusize.productCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": productResponse.string ?? VirtusizeError.unknownError.debugDescription]
			)
			return nil
		}

		let mutableProduct = product
		mutableProduct.name = product.name
		mutableProduct.externalId = product.externalId
		mutableProduct.productCheckData = product.productCheckData

		// Send the API event where the user saw the product
		Task { // should NOT be awaited, to not block the main flow
			await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawProduct),
				withContext: mutableProduct.jsonObject
			)
		}

		guard mutableProduct.productCheckData?.productDataId != nil else {
			NotificationCenter.default.post(
				name: Virtusize.productCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": mutableProduct.dictionary]
			)
			return nil
		}

		if let sendImageToBackend = mutableProduct.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = mutableProduct.productCheckData?.storeId {
			Task { // should NOT be awaited, to not block the main flow
				await VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
			}
		}

		// Send the API event where the user saw the widget button
		Task { // should NOT be awaited, to not block the main flow
			await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawWidgetButton),
				withContext: mutableProduct.jsonObject
			)
		}

		NotificationCenter.default.post(
			name: Virtusize.productCheckDidSucceed,
			object: Virtusize.self,
			userInfo: ["message": mutableProduct.dictionary]
		)

		return mutableProduct
	}

	/// Fetches the initial data such as store product info, product type lists and i18 localization
	///
	/// - Parameters:
	///   - externalProductId: the external product ID provided by the client
	///   - productId: the product ID from the Virtusize server
	/// - Returns: `VirtusizeServerProduct` object loaded from the server, or nil in case of error
	@MainActor
	internal func fetchInitialData(
        externalProductId: String,
        productId: Int?
    ) async -> VirtusizeServerProduct? {
		guard let productId = productId else {
            return nil
		}

		async let serverStoreProductTask = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId)
		async let productTypesTask = VirtusizeAPIService.getProductTypesAsync()
		async let i18nTask = VirtusizeAPIService.getI18nTextsAsync()

		let serverStoreProduct = await serverStoreProductTask.success
		productTypes = await productTypesTask.success
		i18nLocalization = await i18nTask.success

		guard let storeProduct = serverStoreProduct else {
			Virtusize.inPageError = (true, externalProductId)
            return nil
		}
		self.serverStoreProductSet.insert(storeProduct)

		guard productTypes != nil && i18nLocalization != nil else {
			Virtusize.inPageError = (true, externalProductId)
            return nil
		}

        return storeProduct
	}

	/// Fetches data for InPage recommendation
	///
	/// - Parameters:
	///   - selectedUserProductId: the selected product Id from the web view
	///   to decide a specific user product to compare with the store product
	internal func fetchDataForInPageRecommendation(
		storeProduct: VirtusizeServerProduct? = nil,
		selectedUserProductId: Int? = nil,
		shouldUpdateUserProducts: Bool = true,
		shouldUpdateBodyProfile: Bool = true
	) async {
        guard var storeProduct = storeProduct ?? lastProductOnVirtusizeWebView else {
            return
        }

        let productId = storeProduct.id
		if let product = serverStoreProductSet.filter({ product in
			product.id == productId
		   }).first {
			storeProduct = product
		}

		async let userProductsTask = shouldUpdateUserProducts ? VirtusizeAPIService.getUserProductsAsync() : nil
		async let userBodyProfileTask = shouldUpdateBodyProfile && hasSessionBodyMeasurement
			? VirtusizeAPIService.getUserBodyProfileAsync()
			: nil

		let userProductsResponse = await userProductsTask
		let userBodyProfileResponse = await userBodyProfileTask

		if let userProductsResponse = userProductsResponse {
			if userProductsResponse.isSuccessful {
				userProducts = userProductsResponse.success
			} else if userProductsResponse.errorCode != 404 {
				Virtusize.inPageError = (true, storeProduct.externalId)
				return
			}
		}

		if let userBodyProfileResponse = userBodyProfileResponse {
			if userBodyProfileResponse.isSuccessful {
				userBodyProfile = userBodyProfileResponse.success
			} else if userBodyProfileResponse.errorCode != 404 {
				Virtusize.inPageError = (true, storeProduct.externalId)
				return
			}
		} else if !hasSessionBodyMeasurement {
			userBodyProfile = nil // reset body measurements if the user-session defines so
		}

		if let userBodyProfile = userBodyProfile {
            bodyProfileRecommendedSize = await VirtusizeAPIService.getBodyProfileRecommendedSizesAsync(
				productTypes: productTypes!,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile
            ).success?.first
		}

		var userProducts = self.userProducts ?? []
		userProducts = selectedUserProductId != nil ?
			userProducts.filter({ product in return product.id == selectedUserProductId }) : userProducts
		sizeComparisonRecommendedSize = FindBestFitHelper.findBestFitProductSize(
			userProducts: userProducts,
			storeProduct: storeProduct,
			productTypes: productTypes!
		)
	}

	/// Clear user session and the data related to size recommendations
	internal func clearUserData() async {
		UserDefaultsHelper.current.authToken = ""

		userSessionResponse = ""
		userProducts = nil
		sizeComparisonRecommendedSize = nil
		userBodyProfile = nil
        bodyProfileRecommendedSize = nil

		await ExpiringCache.shared.clear(UserSessionInfo.self)
		_ = await VirtusizeAPIService.deleteUserDataAsync()
	}

	/// Updates the user session by calling the session API
	internal func updateUserSession(forceUpdate: Bool = false) async {
		let ttl: TimeInterval = forceUpdate ? .zero : .short
		let userSessionInfoResponse = try? await ExpiringCache.shared.getOrFetch(UserSessionInfo.self, ttl: ttl) {
			await VirtusizeAPIService.getUserSessionInfoAsync()
		}

		if let sessionResponse = userSessionInfoResponse?.string {
			userSessionResponse = sessionResponse
		}

		guard let userSessionInfo = userSessionInfoResponse?.success else {
			return
		}

		UserDefaultsHelper.current.accessToken = userSessionInfo.accessToken
		if !userSessionInfo.authToken.isEmpty {
			UserDefaultsHelper.current.authToken = userSessionInfo.authToken
		}
		hasSessionBodyMeasurement = userSessionInfo.status.hasBodyMeasurement
	}

	/// Updates the browser ID and the auth token from the data of the event user-auth-data
	///
	/// - Parameters:
	///   - bid: a browser identifier
	///   - auth: the auth token for the session API
	internal func updateUserAuthData(bid: String?, auth: String?) {
        if let bid = bid, bid != UserDefaultsHelper.current.undefinedValue {
			UserDefaultsHelper.current.identifier = bid
		}
		if let auth = auth, !auth.isEmpty {
			UserDefaultsHelper.current.authToken = auth
		}
	}

	/// Updates the recommendation for InPage based on the recommendation type
	///
	/// - Parameters:
	///   - product: the designated store product to update
	///   - type: the selected recommendation compare view type
	internal func updateInPageRecommendation(
		product: VirtusizeServerProduct? = nil,
		type: SizeRecommendationType? = nil
	) {
		guard let product = product ?? lastProductOnVirtusizeWebView else {
			return
		}
		switch type {
		case .compareProduct:
			Virtusize.sizeRecData = (product, sizeComparisonRecommendedSize, nil)
		case .body:
			Virtusize.sizeRecData = (product, nil, bodyProfileRecommendedSize)
		default:
			Virtusize.sizeRecData = (product, sizeComparisonRecommendedSize, bodyProfileRecommendedSize)
		}
	}

	/// Updates the user body recommended size
	///
	/// - Parameter recommendedSize the recommended size got from the web view
	internal func updateUserBodyRecommendedSize(_ recommendedSize: String?) {
		guard let recommendedSize = recommendedSize else {
			return
		}
        bodyProfileRecommendedSize = BodyProfileRecommendedSize(sizeName: recommendedSize)
	}

	/// Removes the deleted user product by the product ID from the user product list
	///
	/// - Parameter userProductID the user product ID
	internal func deleteUserProduct(_ userProductID: Int?) {
		guard let userProductID = userProductID else {
			return
		}
		userProducts = userProducts?.filter { userProduct in userProduct.id != userProductID }
	}

	/// The API request for sending an order to the server
	///
	/// - Parameters:
	///   - order: An order to be send to the server
	/// - Throws:`VirtusizeError` back when the request to send an order is unsuccessful
	internal func sendOrder(_ order: VirtusizeOrder) async throws {
		guard let externalUserId = Virtusize.userID else {
			fatalError("Please set Virtusize.userID")
		}
		var mutualOrder = order
		mutualOrder.externalUserId = externalUserId

		let retrieveStoreInfoResponse = await VirtusizeAPIService.retrieveStoreInfoAsync()
		if let storeInfo = retrieveStoreInfoResponse.success {
			mutualOrder.region = storeInfo.region ?? "JP"
		} else {
			throw retrieveStoreInfoResponse.failure ?? .unknownError
		}

		let sendOrderWithRegionResponse = await VirtusizeAPIService.sendOrderWithRegionAsync(mutualOrder)
		if !sendOrderWithRegionResponse.isSuccessful {
			throw sendOrderWithRegionResponse.failure ?? .unknownError
		}
	}
}
