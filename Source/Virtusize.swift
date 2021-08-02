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

import Foundation
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

	/// The array of `VirtusizeView` that clients use on their mobile application
	internal static var virtusizeViews: [VirtusizeView] = []

	/// The array of `VirtusizeView` that is active on the screen of the mobile application
	internal static var activeVirtusizeViews: [VirtusizeView] = []

	/// The singleton instance of `VirtusizeRepository`
	private static var virtusizeRepository = VirtusizeRepository.shared

	internal static let dispatchQueue = DispatchQueue(label: "com.virtusize.default-queue")

	/// The private property for product
	private static var privateProduct: VirtusizeProduct?
	/// The Virtusize product to get the value from the`productDataCheck` request
	public static var product: VirtusizeProduct? {
		set {
			guard let product = newValue else {
				return
			}

			dispatchQueue.async {
				virtusizeRepository.checkProductValidity(product: product) { productWithPDCData in
					if let productWithPDCData = productWithPDCData {
						privateProduct = productWithPDCData
						DispatchQueue.main.async {
							for virtusizeView in activeVirtusizeViews {
								(virtusizeView as? VirtusizeInPageView)?.setup()
								virtusizeView.isLoading()
							}
						}

						virtusizeRepository.fetchInitialData(productId: productWithPDCData.productCheckData?.productDataId) {
							virtusizeRepository.updateUserSession()
							virtusizeRepository.fetchDataForInPageRecommendation()
							virtusizeRepository.switchInPageRecommendation()
						}
					} else {
						DispatchQueue.main.async {
							for virtusizeView in activeVirtusizeViews {
								(virtusizeView as? UIView)?.isHidden = true
							}
						}
					}
				}
			}
		}
		get {
			return privateProduct
		}
	}

	typealias ProductRecommendationData = (
		VirtusizeServerProduct?,
		SizeComparisonRecommendedSize?,
		BodyProfileRecommendedSize?
	)

	/// The private property for updating InPage views
	private static var _updateInPageViews: ProductRecommendationData?
	/// The property to be set to update InPage views.
	internal static var updateInPageViews: ProductRecommendationData? {
		set {
			if newValue?.1 != nil || newValue?.2 != nil {
				DispatchQueue.main.async {
					for virtusizeView in virtusizeRepository.getAvailableVirtusizeViewsBy(externalId: newValue?.0?.externalId) {
						(virtusizeView as? VirtusizeInPageView)?.setInPageRecommendation(
							newValue?.0?.externalId, newValue?.1, newValue?.2
						)
					}
					self.updateInPageViews = (newValue?.0, nil, nil)
				}
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
			if newValue == true {
				DispatchQueue.main.async {
					for virtusizeView in virtusizeViews {
						(virtusizeView as? VirtusizeInPageView)?.showErrorScreen()
					}
					self.showInPageError = false
				}
			}
		}
		get {
			return _showInPageError
		}
	}

    // MARK: - Methods

    /// Sets up the VirtusizeView and adds it to `virtusizeViews`
    public class func setVirtusizeView(_ any: Any, _ view: VirtusizeView) {
		virtusizeRepository.cleanAvailableVSViewToProductDict()
		virtusizeViews = virtusizeViews.filter { $0.isDeallocated != true }

        var mutableView = view
        mutableView.messageHandler = any as? VirtusizeMessageHandler
        mutableView.presentingViewController = any as? UIViewController
		(mutableView as? UIView)?.didMoveToWindow()
        virtusizeViews.append(mutableView)
		activeVirtusizeViews = virtusizeViews.filter { $0.presentingViewController == any as? UIViewController }
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
