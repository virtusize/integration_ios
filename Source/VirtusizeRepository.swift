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
	var storeProduct: VirtusizeInternalProduct?
	var i18nLocalization: VirtusizeI18nLocalization?

	private var userProducts: [VirtusizeInternalProduct]?
	private var userBodyProfile: VirtusizeUserBodyProfile?
	private var bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	private var sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?

	/// Checks if the product in `VirtusizeProduct` is valid and post notifications
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct`
	/// - Returns: true if the product is valid
	internal func isProductValid(product: VirtusizeProduct) -> Bool {
		let productResponse = VirtusizeAPIService.productCheckAsync(product: product)
		guard let product = productResponse.success else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": productResponse.string ?? VirtusizeError.unknownError.debugDescription]
			)
			return false
		}

		Virtusize.internalProduct?.name = product.name
		Virtusize.internalProduct?.externalId = product.externalId
		Virtusize.internalProduct?.productCheckData = product.productCheckData

		// Send the API event where the user saw the product
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawProduct),
			withContext: Virtusize.internalProduct!.jsonObject
		)

		guard Virtusize.internalProduct!.productCheckData?.productDataId != nil else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": Virtusize.internalProduct!.dictionary]
			)
			return false
		}

		if let sendImageToBackend = Virtusize.internalProduct!.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = Virtusize.internalProduct!.productCheckData?.storeId {
			VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
		}

		// Send the API event where the user saw the widget button
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawWidgetButton),
			withContext: Virtusize.internalProduct!.jsonObject
		)

		NotificationCenter.default.post(
			name: Virtusize.productDataCheckDidSucceed,
			object: Virtusize.self,
			userInfo: ["message": Virtusize.internalProduct!.dictionary]
		)

		return true
	}

	/// Fetches the initial data such as store product info, product type lists and i18 localization
	internal func fetchInitialData(productId: Int?) {
		guard let productId = productId else {
			return
		}

		storeProduct = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId).success
		productTypes = VirtusizeAPIService.getProductTypesAsync().success
		i18nLocalization = VirtusizeAPIService.getI18nTextsAsync().success

		if storeProduct == nil || productTypes == nil || i18nLocalization == nil {
			Virtusize.showInPageError = true
		}
	}

	internal func fetchDataForInPageRecommendation(
		shouldUpdateUserProducts: Bool = true,
		selectedUserProductId: Int? = nil
	) {
		if shouldUpdateUserProducts {
			let userProductsResponse = VirtusizeAPIService.getUserProductsAsync()
			if userProductsResponse.isSuccessful {
				userProducts = userProductsResponse.success
			} else if userProductsResponse.errorCode != 404 {
				Virtusize.showInPageError = true
				return
			}
		}

		if selectedUserProductId == nil {
			let userBodyProfileResponse = VirtusizeAPIService.getUserBodyProfileAsync()
			if userBodyProfileResponse.isSuccessful {
				userBodyProfile = userBodyProfileResponse.success
			} else if userBodyProfileResponse.errorCode != 404 {
				Virtusize.showInPageError = true
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

		guard let storeProduct = storeProduct,
			  let productTypes = productTypes else {
			return
		}

		var userProducts = self.userProducts ?? []
		userProducts = selectedUserProductId != nil ?
			userProducts.filter({ product in return product.id == selectedUserProductId }) : userProducts
		sizeComparisonRecommendedSize = FindBestFitHelper.findBestFitProductSize(
			userProducts: userProducts,
			storeProduct: storeProduct,
			productTypes: productTypes
		)
	}

	internal func clearUserData() {
		UserDefaultsHelper.current.authToken = ""

		userProducts = nil
		sizeComparisonRecommendedSize = nil
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

	internal func updateUserAuthData(bid: String?, auth: String?) {
		if let bid = bid {
			UserDefaultsHelper.current.identifier = bid
		}
		if let auth = auth,
		   !auth.isEmpty {
			UserDefaultsHelper.current.authToken = auth
		}
	}

	internal func switchInPageRecommendation(_ selectedRecommendedType: SizeRecommendationType? = nil) {
		switch selectedRecommendedType {
		case .compareProduct:
			Virtusize.updateInPageViews = (sizeComparisonRecommendedSize, nil)
		case .body:
			Virtusize.updateInPageViews = (nil, bodyProfileRecommendedSize)
		default:
			Virtusize.updateInPageViews = (sizeComparisonRecommendedSize, bodyProfileRecommendedSize)
		}
	}

	internal func updateUserBodyRecommendedSize(_ recommendedSize: String?) {
		guard let recommendedSize = recommendedSize else {
			return
		}
		bodyProfileRecommendedSize?.sizeName = recommendedSize
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
