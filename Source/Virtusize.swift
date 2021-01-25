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

    /// Allow process pool to be set to share cookies
    public static var processPool: WKProcessPool?

    /// NotificationCenter observers for debugging the initial product data check
    /// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
    /// with the cause of the failure
    /// - `Virtusize.productDataCheckDidSucceed`
    public static var productDataCheckDidFail = Notification.Name("VirtusizeProductDataCheckDidFail")
    public static var productDataCheckDidSucceed = Notification.Name("VirtusizeProductDataCheckDidSucceed")

	/// The session API response as a string
	internal static var userSessionResponse: String = ""

	/// The array of `VirtusizeView` that clients use on their mobile application
	private static var virtusizeViews: [VirtusizeView] = []

	/// The array of `VirtusizeView` that clients use on their mobile application
	internal static var productTypes: [VirtusizeProductType]?

	internal static var storeProduct: VirtusizeInternalProduct?
	internal static var i18nLocalization: VirtusizeI18nLocalization?
	internal static var bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	internal static var sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?

	/// The internal property for product
	internal static var internalProduct: VirtusizeProduct?
	/// The Virtusize product to get the value from the`productDataCheck` request
	public static var product: VirtusizeProduct? {
		set {
			guard let newValue = newValue else {
				return
			}

			internalProduct = newValue

			DispatchQueue.global().async {
				guard VirtusizeRepository.productCheck(product: newValue) else {
					return
				}

				DispatchQueue.main.async {
					for index in 0...virtusizeViews.count-1 {
						virtusizeViews[index].isLoading()
					}
				}

				VirtusizeRepository.fetchInitialData(productId: internalProduct!.productCheckData!.productDataId)
				VirtusizeRepository.updateSession()
				VirtusizeRepository.updateInPageRecommendation()
			}
		}
		get {
			return internalProduct
		}
	}

	/// The private property for updating InPage views
	private static var _updateInPageViews: Bool?
	/// The property to be set to update InPage views.
	internal static var updateInPageViews: Bool? {
		set {
			if newValue == true {
				DispatchQueue.main.async {
					for index in 0...virtusizeViews.count-1 {
						(virtusizeViews[index] as? VirtusizeInPageView)?.setInPageRecommendation()
					}
					self.updateInPageViews = false
				}
			}
		}
		get {
			return _updateInPageViews
		}
	}

    // MARK: - Methods

    /// Sets up the VirtusizeView and adds it to `virtusizeViews`
    public class func setVirtusizeView(_ any: Any, _ view: VirtusizeView) {
        var mutableView = view
        mutableView.messageHandler = any as? VirtusizeMessageHandler
        mutableView.presentingViewController = any as? UIViewController
        virtusizeViews.append(mutableView)
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
		VirtusizeRepository.sendOrder(
			order,
			onSuccess: onSuccess,
			onError: onError
		)
    }
}
