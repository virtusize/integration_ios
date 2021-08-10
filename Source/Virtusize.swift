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

/// The main class used by Virtusize clients to perform all available operations related to fit check
public class Virtusize {
    // MARK: - Properties

    /// The API key that is unique and provided for Virtusize clients
    public static var APIKey: String?

    /// The user id that is the unique user id from the client system
    public static var userID: String?

    /// The Virtusize environment that defaults to the `global` domain
    public static var environment = VirtusizeEnvironment.global

	/// The Virtusize parameter object contains the parameters to be passed to the Virtusize web app
	public static var params: VirtusizeParams? = VirtusizeParamsBuilder().build()

	/// The display language of the Virtusize integration
	public static let displayLanguage = params?.language

    /// Allow process pool to be set to share cookies
    public static var processPool: WKProcessPool?

    /// NotificationCenter observers for debugging the initial product data check
    /// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
    /// with the cause of the failure
    /// - `Virtusize.productDataCheckDidSucceed`
    public static var productDataCheckDidFail = Notification.Name("VirtusizeProductDataCheckDidFail")
    public static var productDataCheckDidSucceed = Notification.Name("VirtusizeProductDataCheckDidSucceed")

	/// The singleton instance of `VirtusizeRepository`
	private static var virtusizeRepository = VirtusizeRepository.shared

	internal static let dispatchQueue = DispatchQueue(label: "com.virtusize.default-queue")

	internal typealias ProductRecommendationData = (
		serverProduct: VirtusizeServerProduct,
		sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	)

	/// The private property for updating InPage views
	private static var _updateInPageViews: ProductRecommendationData?
	/// The property to be set to update InPage views.
	internal static var updateInPageViews: ProductRecommendationData? {
		set {
			_updateInPageViews = newValue
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .recommendationData, object: _updateInPageViews)
			}
		}
		get {
			return _updateInPageViews
		}
	}

	/// The private property for showing the InPage error screen
	private static var _showInPageError: Bool = false
	/// The property to be set to show the InPage error screen
	internal static var showInPageError: Bool {
		set {
			_showInPageError = newValue
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .inPageError, object: nil)
			}
		}
		get {
			return _showInPageError
		}
	}

    // MARK: - Methods

	public class func load(product: VirtusizeProduct) {
		dispatchQueue.async {
			virtusizeRepository.checkProductValidity(product: product) { productWithPDCData in
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: .productDataCheck, object: productWithPDCData)
				}
				if let productWithPDCData = productWithPDCData {
					virtusizeRepository.fetchInitialData(
						productId: productWithPDCData.productCheckData?.productDataId
					) { storeProduct in
						NotificationCenter.default.post(name: .storeProduct, object: storeProduct)
						virtusizeRepository.updateUserSession()
						virtusizeRepository.fetchDataForInPageRecommendation(storeProduct: storeProduct)
						virtusizeRepository.updateInPageRecommendation(product: storeProduct)
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
		mutableView.product = product
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
