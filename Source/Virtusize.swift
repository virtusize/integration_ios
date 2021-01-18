//
//  Virtusize.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

// swiftlint:disable type_body_length
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

	/// The access token for the API request to get user data
	internal static var accessToken: String? {
		set {
			UserDefaultsHelper.current.accessToken = newValue
		}
		get {
			return UserDefaultsHelper.current.accessToken
		}
	}

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

	/// The private property for product
	private static var _product: VirtusizeProduct?
	/// The Virtusize product to get the value from the`productDataCheck` request
	public static var product: VirtusizeProduct? {
		set {
			guard let product = newValue else {
				return
			}
			VirtusizeAPIService.productCheck(product: product, completion: { product in
				guard let product = product else {
					return
				}
				_product = product
				guard let productId = _product!.productCheckData?.productDataId else {
					return
				}
				for index in 0...virtusizeViews.count-1 {
					virtusizeViews[index].isLoading()
				}
				DispatchQueue.global().async {
					storeProduct = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId).success
					productTypes = VirtusizeAPIService.getProductTypesAsync().success
					i18nLocalization = VirtusizeAPIService.getI18nTextsAsync().success
					updateSession()
					updateInPageRecommendation()
				}
			})
		}
		get {
			return _product
		}
	}

    // MARK: - Methods

	/// Updates the user session by calling the session API
	internal class func updateSession() {
		let userSessionInfoResponse = VirtusizeAPIService.getUserSessionInfoAsync()
		if let accessToken = userSessionInfoResponse.success?.accessToken {
			UserDefaultsHelper.current.accessToken = accessToken
		}
		if let authToken = userSessionInfoResponse.success?.authToken, !authToken.isEmpty {
			UserDefaultsHelper.current.authToken = authToken
		}
		if let sessionResponse = userSessionInfoResponse.string {
			userSessionResponse = sessionResponse
		}
	}

	// swiftlint:disable line_length
	/// Updates the recommendation for InPage
	///
	/// - Parameters:
	///   - selectedUserProductId: Pass the selected product Id from the web view to decide a specific user product to compare with the store product
	///   - ignoreUserData: Pass the boolean vale to determine whether to ignore the API requests that is related to the user data
	internal class func updateInPageRecommendation(selectedUserProductId: Int? = nil, ignoreUserData: Bool = false) {
		var userProducts: [VirtusizeInternalProduct]?
		var userBodyProfile: VirtusizeUserBodyProfile?
		bodyProfileRecommendedSize = nil
		sizeComparisonRecommendedSize = nil
		if !ignoreUserData {
			userProducts = VirtusizeAPIService.getUserProductsAsync().success
			userBodyProfile = VirtusizeAPIService.getUserBodyProfileAsync().success
		}
		if let userProducts = userProducts, let productTypes = productTypes, let storeProduct = storeProduct, let userBodyProfile = userBodyProfile {
			bodyProfileRecommendedSize = VirtusizeAPIService.getBodyProfileRecommendedSizeAsync(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile
			).success
			let userProducts = selectedUserProductId != nil ? userProducts.filter({ product in return product.id == selectedUserProductId })
				: userProducts
			sizeComparisonRecommendedSize = FindBestFitHelper.findBestFitProductSize(
				userProducts: userProducts,
				storeProduct: storeProduct,
				productTypes: productTypes
			)
		}
		DispatchQueue.main.async {
			for index in 0...virtusizeViews.count-1 {
				(virtusizeViews[index] as? VirtusizeInPageView)?.setInPageRecommendation()
			}
		}
	}

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
    public class func sendOrder(_ order: VirtusizeOrder,
                                onSuccess: (() -> Void)? = nil,
                                onError: ((VirtusizeError) -> Void)? = nil) {
		VirtusizeAPIService.sendOrder(
			userID: userID,
			order,
			onSuccess: onSuccess,
			onError: onError
		)
    }
}
