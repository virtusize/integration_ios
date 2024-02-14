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

	static let shared: VirtusizeRepository = {
		let instance = VirtusizeRepository()
		return instance
	}()

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
	private var bodyProfileRecommendedSize: BodyProfileRecommendedSizeArray?

	/// A set to cache the store product information of all the visited products
	private var serverStoreProductSet: Set<VirtusizeServerProduct> = []

	/// Checks if the product in `VirtusizeProduct` is valid and post notifications
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct`
	///   - onProductDataCheck: a closure to pass a valid`VirtusizeProduct` with the PDC data back
	internal func checkProductValidity(
		product: VirtusizeProduct,
		onProductDataCheck: ((VirtusizeProduct?) -> Void)? = nil
	) {
		let productResponse = VirtusizeAPIService.productCheckAsync(product: product)
		guard let product = productResponse.success else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": productResponse.string ?? VirtusizeError.unknownError.debugDescription]
			)
			onProductDataCheck?(nil)
			return
		}

		let mutableProduct = product
		mutableProduct.name = product.name
		mutableProduct.externalId = product.externalId
		mutableProduct.productCheckData = product.productCheckData

		// Send the API event where the user saw the product
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawProduct),
			withContext: mutableProduct.jsonObject
		)

		guard mutableProduct.productCheckData?.productDataId != nil else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": mutableProduct.dictionary]
			)
			onProductDataCheck?(nil)
			return
		}

		if let sendImageToBackend = mutableProduct.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = mutableProduct.productCheckData?.storeId {
			VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
		}

		// Send the API event where the user saw the widget button
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawWidgetButton),
			withContext: mutableProduct.jsonObject
		)

		NotificationCenter.default.post(
			name: Virtusize.productDataCheckDidSucceed,
			object: Virtusize.self,
			userInfo: ["message": mutableProduct.dictionary]
		)

		onProductDataCheck?(mutableProduct)
	}

	/// Fetches the initial data such as store product info, product type lists and i18 localization
	///
	/// - Parameters:
	///   - externalProductId: the external product ID provided by the client
	///   - productId: the product ID from the Virtusize server
	///   - onSuccess: the closure is called if the data from the server is successfully fetched
	internal func fetchInitialData(
		externalProductId: String,
		productId: Int?,
		onSuccess: (VirtusizeServerProduct
		) -> Void) {
		guard let productId = productId else {
			return
		}

		let serverStoreProduct = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId).success

		if serverStoreProduct == nil {
			Virtusize.inPageError = (true, externalProductId)
			return
		}

		self.serverStoreProductSet.insert(serverStoreProduct!)

		productTypes = VirtusizeAPIService.getProductTypesAsync().success
		if productTypes == nil {
			Virtusize.inPageError = (true, externalProductId)
			return
		}

		i18nLocalization = VirtusizeAPIService.getI18nTextsAsync().success
		if i18nLocalization == nil {
			Virtusize.inPageError = (true, externalProductId)
			return
		}

		onSuccess(serverStoreProduct!)
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
	) {
		var storeProduct = storeProduct ?? lastProductOnVirtusizeWebView
		if let productId = storeProduct?.id,
		   let product = serverStoreProductSet.filter({ product in
			product.id == productId
		   }).first {
			storeProduct = product
		}

		if shouldUpdateUserProducts {
			let userProductsResponse = VirtusizeAPIService.getUserProductsAsync()
			if userProductsResponse.isSuccessful {
				userProducts = userProductsResponse.success
			} else if userProductsResponse.errorCode != 404 {
				Virtusize.inPageError = (true, storeProduct!.externalId)
				return
			}
		}

		if shouldUpdateBodyProfile {
			let userBodyProfileResponse = VirtusizeAPIService.getUserBodyProfileAsync()
			if userBodyProfileResponse.isSuccessful {
				userBodyProfile = userBodyProfileResponse.success
			} else if userBodyProfileResponse.errorCode != 404 {
				Virtusize.inPageError = (true, storeProduct!.externalId)
				return
			}
 		}

		if let userBodyProfile = userBodyProfile {
            
			bodyProfileRecommendedSize = VirtusizeAPIService.getBodyProfileRecommendedSizeAsync(
				productTypes: productTypes!,
				storeProduct: storeProduct!,
				userBodyProfile: userBodyProfile
			).success
            
        
            
		}

		var userProducts = self.userProducts ?? []
		userProducts = selectedUserProductId != nil ?
			userProducts.filter({ product in return product.id == selectedUserProductId }) : userProducts
		sizeComparisonRecommendedSize = FindBestFitHelper.findBestFitProductSize(
			userProducts: userProducts,
			storeProduct: storeProduct!,
			productTypes: productTypes!
		)
	}

	/// Clear user session and the data related to size recommendations
	internal func clearUserData() {
		_ = VirtusizeAPIService.deleteUserDataAsync()
		UserDefaultsHelper.current.authToken = ""

		userProducts = nil
		sizeComparisonRecommendedSize = nil
		userBodyProfile = nil
		bodyProfileRecommendedSize = nil
	}

	/// Updates the user session by calling the session API
	internal func updateUserSession() {
		var updateUserSessionResponse = userSessionResponse
		let userSessionInfoResponse = VirtusizeAPIService.getUserSessionInfoAsync()
		if let accessToken = userSessionInfoResponse.success?.accessToken {
			UserDefaultsHelper.current.accessToken = accessToken
		}
		if let authToken = userSessionInfoResponse.success?.authToken, !authToken.isEmpty {
			UserDefaultsHelper.current.authToken = authToken
		}
		if let sessionResponse = userSessionInfoResponse.string {
			updateUserSessionResponse = sessionResponse
		}
		userSessionResponse = updateUserSessionResponse
	}

	/// Updates the browser ID and the auth token from the data of the event user-auth-data
	///
	/// - Parameters:
	///   - bid: a browser identifier
	///   - auth: the auth token for the session API
	internal func updateUserAuthData(bid: String?, auth: String?) {
		if let bid = bid {
			UserDefaultsHelper.current.identifier = bid
		}
		if let auth = auth,
		   !auth.isEmpty {
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
		// swiftlint:disable switch_case_alignment
		switch type {
			case .compareProduct:
				Virtusize.sizeRecData = (product, sizeComparisonRecommendedSize, nil)
			case .body:
            Virtusize.sizeRecData = (product, nil, bodyProfileRecommendedSize?[0])
			default:
            Virtusize.sizeRecData = (product, sizeComparisonRecommendedSize, bodyProfileRecommendedSize?[0])
		}
	}

	/// Updates the user body recommended size
	///
	/// - Parameter recommendedSize the recommended size got from the web view
	internal func updateUserBodyRecommendedSize(_ recommendedSize: String?) {
		guard let recommendedSize = recommendedSize else {
			return
		}
        bodyProfileRecommendedSize?.append(BodyProfileRecommendedSize(sizeName: recommendedSize))
		//bodyProfileRecommendedSize = BodyProfileRecommendedSize(sizeName: recommendedSize)
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
	///   - onSuccess: A callback to be called when the request to send an order is successful
	///   - onError: A callback to pass `VirtusizeError` back when the request to send an order is
	///    unsuccessful
	internal func sendOrder(
		_ order: VirtusizeOrder,
		onSuccess: (() -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) {
		guard let externalUserId = Virtusize.userID else {
			fatalError("Please set Virtusize.userID")
		}
		var mutualOrder = order
		mutualOrder.externalUserId = externalUserId

		let retrieveStoreInfoResponse = VirtusizeAPIService.retrieveStoreInfoAsync()
		if let storeInfo = retrieveStoreInfoResponse.success {
			mutualOrder.region = storeInfo.region ?? "JP"
		} else {
			onError?(retrieveStoreInfoResponse.failure ?? .unknownError)
		}

		let sendOrderWithRegionResponse = VirtusizeAPIService.sendOrderWithRegionAsync(mutualOrder)

		if sendOrderWithRegionResponse.isSuccessful {
			onSuccess?()
		} else {
			onError?(sendOrderWithRegionResponse.failure ?? .unknownError)
		}
	}
}
