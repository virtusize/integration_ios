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
internal class VirtusizeRepository: NSObject { // swiftlint:disable:this type_body_length

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

	private var _store: VirtusizeStore?
	private let storeLock = NSLock()
	private var store: VirtusizeStore? {
		get {
			storeLock.lock()
			defer { storeLock.unlock() }
			return _store
		}
		set {
			storeLock.lock()
			defer { storeLock.unlock() }
			_store = newValue
		}
	}
	private var shouldReloadStoreI18n: Bool = true

	/// A set to cache the store product information of all the visited products
	private var _serverStoreProductSet: Set<VirtusizeServerProduct> = []
	private let productSetLock = NSLock()

	internal var serverStoreProductSet: Set<VirtusizeServerProduct> {
		get {
			productSetLock.lock()
			defer { productSetLock.unlock() }
			return _serverStoreProductSet
		}
		set {
			productSetLock.lock()
			defer { productSetLock.unlock() }
			_serverStoreProductSet = newValue
		}
	}

	/// Thread-safe insert into serverStoreProductSet
	private func insertIntoProductSet(_ product: VirtusizeServerProduct) {
		productSetLock.lock()
		defer { productSetLock.unlock() }
		_serverStoreProductSet.insert(product)
	}

	/// Checks if the product in `VirtusizeProduct` is valid and post notifications
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct`
	/// - Returns: a valid`VirtusizeProduct` with the PDC data or nil if check failed
	internal func checkProductValidity(product: VirtusizeProduct) async -> VirtusizeProduct? {
        let imageURL = product.imageURL
		let productResponse = await VirtusizeAPIService.productCheckAsync(product: product)
		guard let product = productResponse.success else {
            let errorMessage = productResponse.string ?? VirtusizeError.unknownError.debugDescription
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Virtusize.productCheckDidFail,
                    object: Virtusize.self,
                    userInfo: ["message": errorMessage]
                )
            }
			return nil
		}

		let mutableProduct = product
		mutableProduct.name = product.name
		mutableProduct.externalId = product.externalId
		mutableProduct.productCheckData = product.productCheckData
        mutableProduct.imageURL = imageURL

		// Send the API event where the user saw the product
		Task { // should NOT be awaited, to not block the main flow
			await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawProduct),
				withContext: mutableProduct.jsonObject
			)
		}

		guard mutableProduct.productCheckData?.productDataId != nil else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Virtusize.productCheckDidFail,
                    object: Virtusize.self,
                    userInfo: ["message": mutableProduct.dictionary]
                )
            }
			return nil
		}

		if let sendImageToBackend = mutableProduct.productCheckData?.fetchMetaData,
		   sendImageToBackend,
           imageURL != nil,
		   let storeId = mutableProduct.productCheckData?.storeId {
			Task { // should NOT be awaited, to not block the main flow
				await VirtusizeAPIService.sendProductImage(of: mutableProduct, forStore: storeId)
			}
		}

		// Send the API event where the user saw the widget button
		Task { // should NOT be awaited, to not block the main flow
			await VirtusizeAPIService.sendEvent(
				VirtusizeEvent(name: .userSawWidgetButton),
				withContext: mutableProduct.jsonObject
			)
		}
		
		// Post notification on main thread
		DispatchQueue.main.async {
			NotificationCenter.default.post(
				name: Virtusize.productCheckDidSucceed,
				object: Virtusize.self,
				userInfo: ["message": mutableProduct.dictionary]
			)
		}

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
		async let i18nTask = fetchLocalization()

		let serverStoreProduct = await serverStoreProductTask.success
		productTypes = await productTypesTask.success
		i18nLocalization = await i18nTask

		guard let storeProduct = serverStoreProduct else {
			Virtusize.inPageError = (true, externalProductId)
            return nil
		}

		self.insertIntoProductSet(storeProduct)

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
		// Cache externalId early to avoid potential deallocation issues with malformed Unicode
		let externalId = storeProduct.externalId
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
				Virtusize.inPageError = (true, externalId)
				return
			}
		}

		if let userBodyProfileResponse = userBodyProfileResponse {
			if userBodyProfileResponse.isSuccessful {
				userBodyProfile = userBodyProfileResponse.success
			} else if userBodyProfileResponse.errorCode != 404 {
				Virtusize.inPageError = (true, externalId)
				return
			}
		} else if !hasSessionBodyMeasurement {
			userBodyProfile = nil // reset body measurements if the user-session defines so
		}

		if let userBodyProfile = userBodyProfile {
            if storeProduct.isShoe() {
				bodyProfileRecommendedSize = await VirtusizeAPIService.getBodyProfileRecommendedShoeSizeAsync(
					productTypes: productTypes!,
					storeProduct: storeProduct,
					userBodyProfile: userBodyProfile
            	).success
			} else {
				bodyProfileRecommendedSize = await VirtusizeAPIService.getBodyProfileRecommendedItemSizesAsync(
					productTypes: productTypes!,
					storeProduct: storeProduct,
					userBodyProfile: userBodyProfile
            	).success?.first
			}
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
		hasSessionBodyMeasurement = userSessionInfoResponse?.success?.status.hasBodyMeasurement ?? false

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

		if let store = store {
			mutualOrder.region = store.region ?? "JP"
		} else {
			let retrieveStoreInfoResponse = await VirtusizeAPIService.retrieveStoreInfoAsync()
			if let storeInfo = retrieveStoreInfoResponse.success {
				mutualOrder.region = storeInfo.region ?? "JP"
				store = storeInfo
			} else {
				throw retrieveStoreInfoResponse.failure ?? .unknownError
			}
		}

		let sendOrderWithRegionResponse = await VirtusizeAPIService.sendOrderWithRegionAsync(mutualOrder)
		if !sendOrderWithRegionResponse.isSuccessful {
			throw sendOrderWithRegionResponse.failure ?? .unknownError
		}
	}

	/// Fetch i18n Localization as a merge of shared i18n texts and the store specific texts
	///
	/// - Returns: `VirtusizeI18nLocalization` if loaded successfully
	internal func fetchLocalization(language: VirtusizeLanguage? = nil) async -> VirtusizeI18nLocalization? {
		async let i18nTask = VirtusizeAPIService.getI18nAsync(language: language)

		// Capture store value early to avoid concurrent access issues
		let currentStore = store
		let shouldReload = shouldReloadStoreI18n

		async let storeI18nTask: Task<APIResult<JSONObject>?, Error> = Task {
			var storeToUse = currentStore
			if storeToUse == nil {
				let storeInfo = await VirtusizeAPIService.retrieveStoreInfoAsync().success
				storeToUse = storeInfo
				// Update instance property in a thread-safe manner
				self.store = storeInfo
			}

			guard shouldReload else {
				return nil
			}

			guard let storeValue = storeToUse else {
				VirtusizeLogger.warn("Failed to load Store Info")
				return nil
			}

			return await VirtusizeAPIService.getStoreI18nAsync(storeName: storeValue.shortName)
		}

		let i18nResponse = await i18nTask
		guard var i18nJson = i18nResponse.success else {
			VirtusizeLogger.warn("Failed to load i18n: \(i18nResponse.failure?.debugDescription ?? "???")")
			return nil
		}

		guard let storeI18nResponse = try? await storeI18nTask.value else {
			// there is no i18n texts for the current store, simply return default i18n
			return Deserializer.i18n(json: i18nJson)
		}

		if storeI18nResponse.errorCode == 403 {
			shouldReloadStoreI18n = false
			VirtusizeLogger.debug("There is no i18n for current store. Skip trying.")
			return Deserializer.i18n(json: i18nJson)
		}

		guard storeI18nResponse.isSuccessful else {
			VirtusizeLogger.warn("Failed to load store specific texts: \(storeI18nResponse.failure?.debugDescription ?? "???")")
			return nil
		}

		let storeI18n = storeI18nResponse.success?["mobile"] as? JSONObject
		if let lang = language ?? Virtusize.params?.language,
		   let langJson = storeI18n?[lang.rawValue] as? JSONObject,
		   var i18nMergeRoot = i18nJson["keys"] as? JSONObject {

			i18nMergeRoot.deepMerge(source: langJson)
			i18nJson["keys"] = i18nMergeRoot
		}

		return Deserializer.i18n(json: i18nJson)
	}

	internal func setVsWidgetLanguage(language: VirtusizeLanguage) async {
		async let i18nTask = fetchLocalization(language: language)
		i18nLocalization = await i18nTask
	}
} // swiftlint:disable:this file_length
