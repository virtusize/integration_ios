//
//  VirtusizeInPageView.swift
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

public class VirtusizeInPageView: UIView, VirtusizeView, VirtusizeViewEventProtocol {
	/// The property to set the Virtusize view style that this SDK provides
	public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
		didSet {
			setup()
		}
	}

	public var presentingViewController: UIViewController?
	public var messageHandler: VirtusizeMessageHandler?
	public var product: VirtusizeProduct?
	public var serverProduct: VirtusizeServerProduct?

	internal var virtusizeEventHandler: VirtusizeEventHandler?
	internal let defaultMargin: CGFloat = 8
	internal var loadingTextTimer: Timer?

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		virtusizeEventHandler = self
		isHidden = true
		setup()
		addNotificationObserver()
	}

	public override init(frame: CGRect) {
		super.init(frame: .zero)
		virtusizeEventHandler = self
		isHidden = true
		setup()
		addNotificationObserver()
	}

	private func addNotificationObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onProductDataCheck(_:)),
			name: .productDataCheck,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onStoreProduct(_:)),
			name: .storeProduct,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(setInPageRecommendation(_:)),
			name: .recommendationData,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(showErrorScreen(_:)),
			name: .inPageError,
			object: nil
		)
	}

	@objc internal func onProductDataCheck(_ notification: Notification) {
		guard let productWithPDCData = notification.object as? VirtusizeProduct,
			  productWithPDCData.externalId == self.product?.externalId else {
			return
		}
		self.product = productWithPDCData
		isHidden = false
		setLoadingScreen(loading: true)
	}

	@objc internal func onStoreProduct(_ notification: Notification) {
		guard let serverProduct = notification.object as? VirtusizeServerProduct,
			  serverProduct.externalId == self.product?.externalId else {
			return
		}
		self.serverProduct = serverProduct
	}

	/// A parent function to set up InPage recommendation
	@objc internal func setInPageRecommendation(_ notification: Notification) {}

	/// A parent function for showing the error screen
	@objc internal func showErrorScreen(_ notification: Notification) {}

	/// Sets up the styles for the loading screen and the screen after finishing loading
	///
	/// - Parameters:
	///   - loading: Pass true when it's loading, and pass false when finishing loading
	internal func setLoadingScreen(loading: Bool) {}

	internal func setup() {}

	internal func setHorizontalMargins(view: UIView, margin: CGFloat) {
		view.addConstraint(
			NSLayoutConstraint(
				item: self,
				attribute: .leading,
				relatedBy: .equal,
				toItem: view,
				attribute: .leading,
				multiplier: 1,
				constant: margin
			)
		)
		view.addConstraint(
			NSLayoutConstraint(
				item: view,
				attribute: .trailing,
				relatedBy: .equal,
				toItem: self,
				attribute: .trailing,
				multiplier: 1,
				constant: margin
			)
		)
	}

	@objc internal func clickInPageViewAction() {
		openVirtusizeWebView(
			product: product,
			serverProduct: serverProduct,
			eventHandler: virtusizeEventHandler
		)
	}

	internal func startLoadingTextAnimation(label: UILabel, text: String) {
		var tempDots = 0
		label.text = text
		if loadingTextTimer == nil {
			loadingTextTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
				if tempDots == 3 {
					tempDots = 0
					label.text = text
				} else {
					tempDots += 1
					label.text = "\(text)" + String(repeating: "·", count: tempDots)
				}
			}
		}
	}

	internal func stopLoadingTextAnimation() {
		self.loadingTextTimer?.invalidate()
		self.loadingTextTimer = nil
	}
}

extension VirtusizeInPageView: VirtusizeEventHandler {

	public func userOpenedWidget() {
		handleUserOpenedWidget()
	}

	public func userAuthData(bid: String?, auth: String?) {
		handleUserAuthData(bid: bid, auth: auth)
	}

	public func userSelectedProduct(userProductId: Int?) {
		handleUserSelectedProduct(userProductId: userProductId)
	}

	public func userAddedProduct() {
		handleUserAddedProduct()
	}

	public func userDeletedProduct(userProductId: Int?) {
		handleUserDeletedProduct(userProductId: userProductId)
	}

	public func userChangedRecommendationType(changedType: SizeRecommendationType?) {
		handleUserChangedRecommendationType(changedType: changedType)
	}

	public func userUpdatedBodyMeasurements(recommendedSize: String?) {
		handleUserUpdatedBodyMeasurements(recommendedSize: recommendedSize)
	}

	public func userLoggedIn() {
		handleUserLoggedIn()
	}

	public func clearUserData() {
		handleClearUserData()
	}
}
