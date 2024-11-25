//
//  VirtusizeView.swift
//
//  Copyright (c) 2020 Virtusize KK
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

/// A protocol for the Virtusize specific views such as `VirtusizeButton` and `VirtusizeInPageView`
public protocol VirtusizeView {
	var style: VirtusizeViewStyle { get }
	var presentingViewController: UIViewController? { get set }
	var messageHandler: VirtusizeMessageHandler? { get set }
	var clientProduct: VirtusizeProduct? { get set }
	var serverProduct: VirtusizeServerProduct? { get set }
}

/// Extension functions for `VirtusizeView`
extension VirtusizeView {

	/// Opens the Virtusize web view
	internal func openVirtusizeWebView(
		product: VirtusizeProduct? = nil,
		serverProduct: VirtusizeServerProduct? = nil,
		eventHandler: VirtusizeEventHandler? = nil
	) {
		VirtusizeRepository.shared.lastProductOnVirtusizeWebView = self.serverProduct
		if let virtusize = VirtusizeWebViewController(
			product: product,
			messageHandler: messageHandler,
			eventHandler: eventHandler,
			processPool: Virtusize.processPool
		) {
			presentingViewController?.present(virtusize, animated: true, completion: nil)
		}
	}

	internal func shouldUpdateProductCheckData(
		_ notification: Notification,
		onProductCheckData: (VirtusizeProduct) -> Void
	) {
		guard let notificationData = notification.userInfo as? [String: Any],
			let productWithPDCData = notificationData[NotificationKey.productCheckData] as? VirtusizeProduct,
			productWithPDCData.externalId == self.clientProduct?.externalId else {
			return
		}
		onProductCheckData(productWithPDCData)
	}

	internal func shouldUpdateStoreProduct(
		_ notification: Notification,
		onStoreProduct: (VirtusizeServerProduct) -> Void
	) {
		guard let notificationData = notification.userInfo as? [String: Any],
			let storeProduct = notificationData[NotificationKey.storeProduct] as? VirtusizeServerProduct,
			storeProduct.externalId == self.clientProduct?.externalId else {
			return
		}
		onStoreProduct(storeProduct)
	}
}
