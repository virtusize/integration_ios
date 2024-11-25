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
        didSet{
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
	private static var virtusizeRepository = VirtusizeRepository.shared

	internal static let dispatchQueue = DispatchQueue(label: "com.virtusize.default-queue")

	internal typealias SizeRecommendationData = (
		serverProduct: VirtusizeServerProduct,
		sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	)

	/// The private property for updating the size recommendation data for InPage views
	private static var _sizeRecData: SizeRecommendationData?
	/// The property to be set to updating the size recommendation data for InPage views.
	internal static var sizeRecData: SizeRecommendationData? {
		set {
			_sizeRecData = newValue
			if let sizeRecData = _sizeRecData {
				DispatchQueue.main.async {
					NotificationCenter.default.post(
						name: .sizeRecommendationData,
						object: Virtusize.self,
						userInfo: [NotificationKey.sizeRecommendationData: sizeRecData as SizeRecommendationData]
					)
				}
			}
		}
		get {
			return _sizeRecData
		}
	}

	internal typealias InPageError = (hasError: Bool, externalProductId: String)

	/// The property to be set to show the InPage error screen with the associated external product ID
	private static var _inPageError: InPageError?
	/// The property to be set to show the InPage error screen with the associated external product ID
	internal static var inPageError: InPageError? {
		set {
			_inPageError = newValue
			if let inPageError = _inPageError {
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
		get {
			return _inPageError
		}
	}

	// MARK: - Methods
	/// A function for clients to populate the Virtusize views by loading a product
	public class func load(product: VirtusizeProduct) {
		dispatchQueue.async {
			virtusizeRepository.checkProductValidity(product: product) { productWithPDCData in
				if let productWithPDCData = productWithPDCData {
                    virtusizeRepository.updateUserSession()
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: .productCheckData,
							object: Virtusize.self,
							userInfo: [NotificationKey.productCheckData: productWithPDCData]
						)
					}
					virtusizeRepository.fetchInitialData(
						externalProductId: product.externalId,
						productId: productWithPDCData.productCheckData?.productDataId
                    ) { serverProduct in
                        NotificationCenter.default.post(
                            name: .storeProduct,
                            object: Virtusize.self,
                            userInfo: [NotificationKey.storeProduct: serverProduct]
                        )
                        virtusizeRepository.fetchDataForInPageRecommendation(storeProduct: serverProduct)
                        virtusizeRepository.updateInPageRecommendation(product: serverProduct)
                    }
				}
			}
		}
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
		virtusizeRepository.sendOrder(
			order,
			onSuccess: onSuccess,
			onError: onError
		)
	}
}
