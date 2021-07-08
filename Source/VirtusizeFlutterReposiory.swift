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

public class VirtusizeFlutterRepository: NSObject {
	public static let shared: VirtusizeFlutterRepository = {
		let instance = VirtusizeFlutterRepository()
		return instance
	}()

	public func getProductDataCheck(product: VirtusizeProduct) -> (VirtusizeProduct?, String?) {
		let productResponse = VirtusizeAPIService.productCheckAsync(product: product)
		var isValidProduct: Bool = false
		sendEventsAndProductImage(productResponse: productResponse) { isValid in
			isValidProduct = isValid
		}
		return (isValidProduct ? productResponse.success : nil, isValidProduct ? productResponse.string : nil)
	}

	private func sendEventsAndProductImage(
		productResponse: APIResult<VirtusizeProduct>,
		onValidProduct: (Bool) -> Void
	) {
		guard let product = productResponse.success else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": productResponse.string ?? VirtusizeError.unknownError.debugDescription]
			)
			onValidProduct(false)
			return
		}

		// Send the API event where the user saw the product
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawProduct),
			withContext: product.jsonObject
		)

		guard product.productCheckData?.productDataId != nil else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": product.dictionary]
			)
			onValidProduct(false)
			return
		}

		if let sendImageToBackend = product.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = product.productCheckData?.storeId {
			VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
		}

		// Send the API event where the user saw the widget button
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawWidgetButton),
			withContext: product.jsonObject
		)

		NotificationCenter.default.post(
			name: Virtusize.productDataCheckDidSucceed,
			object: Virtusize.self,
			userInfo: ["message": product.dictionary]
		)

		onValidProduct(true)
	}

	public func getStoreProduct(productId: Int) -> VirtusizeStoreProduct? {
		let response = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId)
		return response.isSuccessful ? response.success : nil
	}

	public func getProductTypes() -> [VirtusizeProductType]? {
		let response = VirtusizeAPIService.getProductTypesAsync()
		return response.isSuccessful ? response.success : nil
	}

	public func getI18nLocalization() -> VirtusizeI18nLocalization? {
		let response = VirtusizeAPIService.getI18nTextsAsync()
		return response.isSuccessful ? response.success : nil
	}

	public func getUserSessionResponse() -> String? {
		let userSessionInfoResponse = VirtusizeAPIService.getUserSessionInfoAsync()
		if let accessToken = userSessionInfoResponse.success?.accessToken {
			UserDefaultsHelper.current.accessToken = accessToken
		}
		if let authToken = userSessionInfoResponse.success?.authToken, !authToken.isEmpty {
			UserDefaultsHelper.current.authToken = authToken
		}
		return userSessionInfoResponse.isSuccessful ? userSessionInfoResponse.string : nil
	}

	public func getUserProducts() -> [VirtusizeStoreProduct]? {
		let response = VirtusizeAPIService.getUserProductsAsync()
		return response.isSuccessful || response.errorCode == 404 ? response.success ?? [] : nil
	}

	public func getUserBodyProfile() -> (VirtusizeUserBodyProfile?, Int?) {
		let response = VirtusizeAPIService.getUserBodyProfileAsync()
		return (response.success, response.errorCode)
	}

	public func getBodyProfileRecommendedSize(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeStoreProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) -> BodyProfileRecommendedSize? {
		let response = VirtusizeAPIService.getBodyProfileRecommendedSizeAsync(
			productTypes: productTypes,
			storeProduct: storeProduct,
			userBodyProfile: userBodyProfile
		)
		return response.isSuccessful ? response.success : nil
	}

	public func getRecommendationText(
		selectedRecType: SizeRecommendationType? = nil,
		userProducts: [VirtusizeStoreProduct]? = nil,
		storeProduct: VirtusizeStoreProduct,
		productTypes: [VirtusizeProductType],
		bodyProfileRecommendedSize: BodyProfileRecommendedSize?,
		i18nLocalization: VirtusizeI18nLocalization
	) -> String {
		var userProductRecommendedSize: SizeComparisonRecommendedSize?
		var userBodyRecommendedSize: String?

		if selectedRecType != SizeRecommendationType.body {
			userProductRecommendedSize = FindBestFitHelper.findBestFitProductSize(
				userProducts: userProducts ?? [],
				storeProduct: storeProduct,
				productTypes: productTypes
			)
		}

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
		if let bid = bid {
			UserDefaultsHelper.current.identifier = bid
		}
		if let auth = auth, !auth.isEmpty {
			UserDefaultsHelper.current.authToken = auth
		}
	}

	public func deleteUser() {
		let response = VirtusizeAPIService.deleteUserDataAsync()
		if response.isSuccessful {
			UserDefaultsHelper.current.authToken = ""
		}
	}

	public func getPrivacyPolicyLink() -> String {
		return Localization.shared.localize("privacy_policy_link")
	}
}
