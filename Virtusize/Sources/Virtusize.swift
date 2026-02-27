//
//  Virtusize.swift
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

import WebKit
import VirtusizeCore

/// The main class used by Virtusize clients to perform all available operations related to fit check
public class Virtusize {
	// MARK: - Properties

	/// The API key that is unique and provided for Virtusize clients
	public static var APIKey: String?

	/// The user id that is the unique user id from the client system
	public static var userID: String? {
		didSet {
			APICache.shared.currentUserId = Virtusize.userID
		}
	}

	/// The Virtusize environment that defaults to the `GLOBAL` domain
	public static var environment = VirtusizeEnvironment.GLOBAL

	/// The Virtusize parameter object contains the parameters to be passed to the Virtusize web app
	public static var params: VirtusizeParams? = VirtusizeParamsBuilder().build()

	/// The display language of the Virtusize integration
	public static let displayLanguage = params?.language

	/// Allow process pool to be set to share cookies
	public static var processPool: WKProcessPool?

	/// NotificationCenter observers for debugging the initial product data check
	/// - `Virtusize.productCheckDidFail`, the `UserInfo` will contain a message
	/// with the cause of the failure
	/// - `Virtusize.productCheckDidSucceed`
	public static var productCheckDidFail = Notification.Name("VirtusizeProductCheckDidFail")
	public static var productCheckDidSucceed = Notification.Name("VirtusizeProductCheckDidSucceed")

	/// The singleton instance of `VirtusizeRepository`
	private static let virtusizeRepository = VirtusizeRepository.shared

	internal static let virtusizeEventHandler = DefaultEventHandler()

	/// Task to track current product load operation for cancellation
	private static var loadProductTask: Task<Void, Never>?
	private static let loadProductTaskLock = NSLock()

	internal typealias SizeRecommendationData = ( // swiftlint:disable:this large_tuple
		serverProduct: VirtusizeServerProduct,
		sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	)

	/// Lock for thread-safe access to sizeRecData
	private static let sizeRecDataLock = NSLock()
	
	/// The backing storage for size recommendation data
	private static var _sizeRecData: SizeRecommendationData?
	
	/// The property to be set to updating the size recommendation data for InPage views.
	internal static var sizeRecData: SizeRecommendationData? {
		get {
			sizeRecDataLock.lock()
			defer { sizeRecDataLock.unlock() }
			return _sizeRecData
		}
		set {
			sizeRecDataLock.lock()
			_sizeRecData = newValue
			let value = _sizeRecData
			sizeRecDataLock.unlock()
			
			if let sizeRecData = value {
				DispatchQueue.main.async {
					NotificationCenter.default.post(
						name: .sizeRecommendationData,
						object: Virtusize.self,
						userInfo: [NotificationKey.sizeRecommendationData: sizeRecData as SizeRecommendationData]
					)
				}
			}
		}
	}

	internal typealias InPageError = (hasError: Bool, externalProductId: String)

	/// The property to be set to show the InPage error screen with the associated external product ID
	internal static var inPageError: InPageError? {
		didSet {
			if let inPageError = inPageError {
				DispatchQueue.main.async {
					NotificationCenter.default.post(
						name: .inPageError,
						object: Virtusize.self,
						userInfo: [
							NotificationKey.inPageError: inPageError as InPageError]
					)
				}
			}
		}
	}

	// MARK: - Methods
	/// A function for clients to populate the Virtusize views by loading a product
	public class func load(product: VirtusizeProduct) {
		// Cancel previous load task if it exists
		loadProductTaskLock.lock()
		loadProductTask?.cancel()

		// Create new task
		let task = Task {
			// Check if cancelled early
			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "start", externalProductId: product.externalId)
				return
			}

			let productWithPDCData = await virtusizeRepository.checkProductValidity(product: product)

			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "product-check", externalProductId: product.externalId)
				return
			}
			guard let productWithPDCData = productWithPDCData else {
                VirtusizeSentryTracker.trackProductCheck(externalProductId: product.externalId, isValid: false)
                VirtusizeSentryTracker.trackError(
                    NSError(domain: "Virtusize", code: 0, userInfo: [NSLocalizedDescriptionKey: "Product check failed"]),
                    storeId: nil
                )
                inPageError = (true, product.externalId)
                return
			}

			let storeId = productWithPDCData.productCheckData.map { String($0.storeId) }
			let isValidProduct = productWithPDCData.productCheckData?.validProduct ?? true
			VirtusizeSentryTracker.trackProductCheck(externalProductId: product.externalId, isValid: isValidProduct, storeId: storeId)

			VirtusizeSentryTracker.generateSessionId()
			VirtusizeSentryTracker.trackUserSawProduct(externalProductId: product.externalId, storeId: storeId)

			await virtusizeRepository.updateUserSession()

			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "user-session", externalProductId: product.externalId, storeId: storeId)
				return
			}
			await MainActor.run {
				NotificationCenter.default.post(
					name: .productCheckData,
					object: Virtusize.self,
					userInfo: [NotificationKey.productCheckData: productWithPDCData]
				)
			}

			let serverProduct = await virtusizeRepository.fetchInitialData(
				externalProductId: product.externalId,
				productId: productWithPDCData.productCheckData?.productDataId
			)

			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "fetch-initial-data", externalProductId: product.externalId, storeId: storeId)
				return
			}
			guard let serverProduct = serverProduct else {
                VirtusizeSentryTracker.trackError(
                    NSError(domain: "Virtusize", code: 0, userInfo: [NSLocalizedDescriptionKey: "Fetch initial data failed"]),
                    storeId: storeId
                )
                inPageError = (true, product.externalId)
				return
			}

			await MainActor.run {
				NotificationCenter.default.post(
					name: .storeProduct,
					object: Virtusize.self,
					userInfo: [NotificationKey.storeProduct: serverProduct]
				)
			}

			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "store-product", externalProductId: product.externalId, storeId: storeId)
				return
			}
			await virtusizeRepository.fetchDataForInPageRecommendation(storeProduct: serverProduct)

			guard !Task.isCancelled else {
				VirtusizeSentryTracker.trackLoadCancelled(step: "fetch-recommendations", externalProductId: product.externalId, storeId: storeId)
				return
			}
			await MainActor.run {
				virtusizeRepository.updateInPageRecommendation(product: serverProduct)
			}
		}

		loadProductTask = task
		loadProductTaskLock.unlock()
	}

	/// Sets up the VirtusizeView and adds it to `virtusizeViews`
	public class func setVirtusizeView(
		_ any: Any,
		_ view: VirtusizeView,
		product: VirtusizeProduct
	) {
		var mutableView = view
		mutableView.messageHandler = any as? VirtusizeMessageHandler
		mutableView.presentingViewController = any as? UIViewController
		mutableView.clientProduct = product
	}

	/// The API request for sending an order to the server
	///
	/// - Parameters:
	///   - order: An order to be send to the server
	///   - onSuccess: A callback to be called when the request to send an order is successful
	///   - onError: A callback to pass `VirtusizeError` back when the request to send an order is
	///    unsuccessful
	public class func sendOrder(
		_ order: VirtusizeOrder,
		onSuccess: (() -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) {
		Task {
			do {
				let storeId = APICache.shared.currentStoreId.map { String($0) }
				VirtusizeSentryTracker.trackSendOrder(order: order, storeId: storeId)
				try await virtusizeRepository.sendOrder(order)
				onSuccess?()
			} catch let error as VirtusizeError {
				VirtusizeSentryTracker.trackError(error, storeId: APICache.shared.currentStoreId.map { String($0) })
				onError?(error)
			}
		}
	}

	/// Handles the OAuth callback. Returns true if the URL is known and handled by the SDK
	///
	/// - Parameters:
	///   - url: OAuth callback URL
	public class func handleUrl(_ url: URL) -> Bool {
		return VirtusizeAuthorization.shared.handleUrl(url)
	}

	/// Sets the display language for the Virtusize views
	///
	/// - Parameter language: VirtusizeLanguage to be set for the views
	public class func setVsWidgetLanguage(language: VirtusizeLanguage) async {
		await virtusizeRepository.setVsWidgetLanguage(language: language)
		params = params?.withLanguage(language)
        DispatchQueue.main.async {
			NotificationCenter.default.post(
				name: .setLanguage,
				object: Virtusize.self,
				userInfo: [NotificationKey.setLanguage: language]
			)
		}
	}
}
