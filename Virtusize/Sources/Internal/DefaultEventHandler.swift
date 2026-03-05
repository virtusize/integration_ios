//
//  DefaultEventHandler.swift
//  Virtusize
//
//  Copyright (c) 2025-present Virtusize KK
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

import VirtusizeCore

internal class DefaultEventHandler: VirtusizeEventHandler, VirtusizeViewEventProtocol {
	var virtusizeEventHandler: VirtusizeEventHandler?

    private var sentryStoreId: String? {
        APICache.shared.currentStoreId.map { String($0) }
    }

	public func userOpenedWidget() {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userOpenedWidget.rawValue,
            storeId: sentryStoreId
        )
		handleUserOpenedWidget()
	}

	public func userAuthData(bid: String?, auth: String?) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userAuthData.rawValue,
            storeId: sentryStoreId
        )
		handleUserAuthData(bid: bid, auth: auth)
	}

	public func userSelectedProduct(userProductId: Int?) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userSelectedProduct.rawValue,
            storeId: sentryStoreId
        )
		handleUserSelectedProduct(userProductId: userProductId)
	}

	public func userAddedProduct() {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userAddedProduct.rawValue,
            storeId: sentryStoreId
        )
		handleUserAddedProduct()
	}

	public func userDeletedProduct(userProductId: Int?) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userDeletedProduct.rawValue,
            storeId: sentryStoreId
        )
		handleUserDeletedProduct(userProductId: userProductId)
	}

	public func userChangedRecommendationType(changedType: SizeRecommendationType?) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userChangedRecommendationType.rawValue,
            storeId: sentryStoreId
        )
		handleUserChangedRecommendationType(changedType: changedType)
	}

	public func userUpdatedBodyMeasurements(recommendedSize: String?) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userUpdatedBodyMeasurements.rawValue,
            storeId: sentryStoreId
        )
		handleUserUpdatedBodyMeasurements(recommendedSize: recommendedSize)
	}

	public func userLoggedIn() {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userLoggedIn.rawValue,
            storeId: sentryStoreId
        )
		handleUserLoggedIn()
	}

	public func clearUserData() {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: "user-clear-data",
            storeId: sentryStoreId
        )

		handleClearUserData()
	}

	public func userClosedWidget() {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userClosedWidget.rawValue,
            storeId: sentryStoreId
        )

		handleUserClosedWidget()
	}

	public func userClickedLanguageSelector(language: VirtusizeLanguage) {
        VirtusizeSentryTracker.shared.trackWebViewEvent(
            eventName: VirtusizeEventName.userClickedLanguageSelector.rawValue,
            storeId: sentryStoreId
        )
		handleUserClickedLanguageSelector(language: language)
	}
}
