//
//  VirtusizeFlutterRepository.swift
//
//  Copyright (c) 2021-present Virtusize KK
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

public class VirtusizeFlutterRepository: NSObject {
	public static let shared: VirtusizeFlutterRepository = {
		let instance = VirtusizeFlutterRepository()
		return instance
	}()

	public func getProductCheckData(
		messageHandler: VirtusizeMessageHandler?,
		product: VirtusizeProduct
	) async -> (VirtusizeProduct?, String?) {
		let productResponse = await VirtusizeAPIService.productCheckAsync(product: product)
		let isValidProduct = await sendEventsAndProductImage(
			messageHandler: messageHandler,
			productResponse: productResponse
		)
		return (isValidProduct ? productResponse.success : nil, isValidProduct ? productResponse.string : nil)
	}

	private func sendEventsAndProductImage(
		messageHandler: VirtusizeMessageHandler?,
		productResponse: APIResult<VirtusizeProduct>
	) async -> Bool {
		guard let product = productResponse.success else {
			return false
		}

		// Send the API event where the user saw the product
		Task {
			let eventJSONObject = await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawProduct),
				withContext: product.jsonObject
			)
			messageHandler?.virtusizeController(
				nil,
				didReceiveEvent: VirtusizeEvent(
					name: VirtusizeEventName.userSawProduct.rawValue,
					data: eventJSONObject
				)
			)
		}

		guard product.productCheckData?.productDataId != nil else {
			return false
		}

		if let sendImageToBackend = product.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = product.productCheckData?.storeId {
			_ = await VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
		}

		// Send the API event where the user saw the widget button
		Task {
			let eventJSONObject = await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawWidgetButton),
				withContext: product.jsonObject
			)
			messageHandler?.virtusizeController(
				nil,
				didReceiveEvent:
					VirtusizeEvent(
						name: VirtusizeEventName.userSawWidgetButton.rawValue,
						data: eventJSONObject
					)
			)
		}

		return true
	}

	public func getStoreProduct(productId: Int) async -> VirtusizeServerProduct? {
		let response = await VirtusizeAPIService.getStoreProductInfoAsync(productId: productId)
		return response.isSuccessful ? response.success : nil
	}

	public func getProductTypes() async -> [VirtusizeProductType]? {
		let response = await VirtusizeAPIService.getProductTypesAsync()
		return response.isSuccessful ? response.success : nil
	}

	public func getI18nLocalization() async -> VirtusizeI18nLocalization? {
		let response = await VirtusizeAPIService.getI18nAsync()
		return response.isSuccessful ? Deserializer.i18n(json: response.success) : nil
	}

	public func getUserSessionResponse() async -> String? {
		let userSessionInfoResponse = await VirtusizeAPIService.getUserSessionInfoAsync()
		if let accessToken = userSessionInfoResponse.success?.accessToken {
			UserDefaultsHelper.current.accessToken = accessToken
		}
		if let authToken = userSessionInfoResponse.success?.authToken, !authToken.isEmpty {
			UserDefaultsHelper.current.authToken = authToken
		}
		return userSessionInfoResponse.isSuccessful ? userSessionInfoResponse.string : nil
	}

	public func getUserProducts() async -> [VirtusizeServerProduct]? {
		let response = await VirtusizeAPIService.getUserProductsAsync()
		return response.isSuccessful || response.errorCode == 404 ? response.success ?? [] : nil
	}

	public func getUserBodyProfile() async -> (VirtusizeUserBodyProfile?, Int?) {
		let response = await VirtusizeAPIService.getUserBodyProfileAsync()
		return (response.success, response.errorCode)
	}

	public func getBodyProfileRecommendedSize(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeServerProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) async -> BodyProfileRecommendedSizeArray? {
		let response = await VirtusizeAPIService.getBodyProfileRecommendedSizesAsync(
			productTypes: productTypes,
			storeProduct: storeProduct,
			userBodyProfile: userBodyProfile
		)
		return response.isSuccessful ? response.success : nil
	}

	public func getUserProductRecommendedSize(
		selectedRecType: SizeRecommendationType? = nil,
		userProducts: [VirtusizeServerProduct]? = nil,
		storeProduct: VirtusizeServerProduct,
		productTypes: [VirtusizeProductType]
	) -> SizeComparisonRecommendedSize? {
		var userProductRecommendedSize: SizeComparisonRecommendedSize?

		if selectedRecType != SizeRecommendationType.body {
			userProductRecommendedSize = FindBestFitHelper.findBestFitProductSize(
				userProducts: userProducts ?? [],
				storeProduct: storeProduct,
				productTypes: productTypes
			)
		}

		return userProductRecommendedSize
	}

	public func getRecommendationText(
		selectedRecType: SizeRecommendationType? = nil,
		storeProduct: VirtusizeServerProduct,
		userProductRecommendedSize: SizeComparisonRecommendedSize?,
		bodyProfileRecommendedSize: BodyProfileRecommendedSize?,
		i18nLocalization: VirtusizeI18nLocalization
	) -> String {
		var userBodyRecommendedSize: String?

		if selectedRecType != SizeRecommendationType.compareProduct {
			userBodyRecommendedSize = bodyProfileRecommendedSize?.sizeName
		}

		return storeProduct.getRecommendationText(
			i18nLocalization,
			userProductRecommendedSize,
			userBodyRecommendedSize,
			VirtusizeI18nLocalization.TrimType.MULTIPLELINES
		)
	}

	public func updateUserAuthData(bid: String?, auth: String?) {
        if let bid = bid, bid != UserDefaultsHelper.current.undefinedValue {
			UserDefaultsHelper.current.identifier = bid
		}
		if let auth = auth, !auth.isEmpty {
			UserDefaultsHelper.current.authToken = auth
		}
	}

	public func deleteUser() async {
		let response = await VirtusizeAPIService.deleteUserDataAsync()
		if response.isSuccessful {
			UserDefaultsHelper.current.authToken = ""
		}
	}

	public func getPrivacyPolicyLink() -> String {
		return Localization.shared.localize("privacy_policy_link")
	}

	public func sendOrder(
		_ orderDict: [String: Any?],
		onSuccess: (() -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) async {
		guard let externalUserId = Virtusize.userID else {
			fatalError("Please set Virtusize.userID")
		}

		guard let order = VirtusizeOrder.convertToObjectBy(dictionary: orderDict) else {
			onError?(VirtusizeError.encodingError)
			return
		}

		var mutualOrder = order
		mutualOrder.apiKey = Virtusize.APIKey
		mutualOrder.externalUserId = externalUserId

		let retrieveStoreInfoResponse = await VirtusizeAPIService.retrieveStoreInfoAsync()
		if let storeInfo = retrieveStoreInfoResponse.success {
			mutualOrder.region = storeInfo.region ?? "JP"
		} else {
			onError?(retrieveStoreInfoResponse.failure ?? .unknownError)
		}

		let sendOrderWithRegionResponse = await VirtusizeAPIService.sendOrderWithRegionAsync(mutualOrder)

		if sendOrderWithRegionResponse.isSuccessful {
			onSuccess?()
		} else {
			onError?(sendOrderWithRegionResponse.failure ?? .unknownError)
		}
	}
}
