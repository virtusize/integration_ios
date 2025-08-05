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

import UIKit

public class VirtusizeInPageView: UIView, VirtusizeView, VirtusizeViewEventProtocol {
	/// The property to set the Virtusize view style that this SDK provides
	public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
		didSet {
			setup()
		}
	}

	public var presentingViewController: UIViewController?
	public var messageHandler: VirtusizeMessageHandler?
	public var clientProduct: VirtusizeProduct?
	public var serverProduct: VirtusizeServerProduct?

	internal var virtusizeEventHandler: VirtusizeEventHandler?
	internal let defaultMargin: CGFloat = 8
	internal var loadingTextTimer: Timer?

	internal var contentViewListener: ((VirtusizeInPageView) -> Void)?
	internal var userSetMargin: CGFloat = 0

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		virtusizeEventHandler = self
		addSubviews()
		setup()
		addNotificationObserver()
	}

	public override init(frame: CGRect) {
		super.init(frame: .zero)
		virtusizeEventHandler = self
		addSubviews()
		setup()
		addNotificationObserver()
	}

	// Container for all current content
	internal let contentContainerView: UIView = UIView()
	// Loading GIF image view
	private let loadingGifImageView: UIImageView = UIImageView()
    internal var isLoading: Bool = false
    internal var isError: Bool = false

	private func addSubviews() {
		// Add loading GIF image view
		addSubview(loadingGifImageView)
		loadingGifImageView.translatesAutoresizingMaskIntoConstraints = false
		loadingGifImageView.contentMode = .scaleAspectFit
        loadingGifImageView.image = UIImage.animatedGif(named: "virtusize_loading")
		NSLayoutConstraint.activate([
			loadingGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			loadingGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			loadingGifImageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			loadingGifImageView.heightAnchor.constraint(equalToConstant: 40)
		])
		loadingGifImageView.isHidden = false

		// Add content container view
		addSubview(contentContainerView)
		contentContainerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			contentContainerView.topAnchor.constraint(equalTo: topAnchor),
			contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
			contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
		contentContainerView.isHidden = true
	}

	internal func showLoadingGif(_ show: Bool) {
		isHidden = false
        isLoading = show
		loadingGifImageView.isHidden = !show
		contentContainerView.isHidden = show
	}

	/// Add observers to listen to notification data from the sender (Virtusize.self)
	private func addNotificationObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveProductCheckData(_:)),
			name: .productCheckData,
			object: Virtusize.self
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveStoreProduct(_:)),
			name: .storeProduct,
			object: Virtusize.self
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveSizeRecommendationData(_:)),
			name: .sizeRecommendationData,
			object: Virtusize.self
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveInPageError(_:)),
			name: .inPageError,
			object: Virtusize.self
		)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveSetLanguageEvent(_:)),
            name: .setLanguage,
            object: Virtusize.self
        )
	}
    
    @objc internal func didReceiveSetLanguageEvent(_ notification: Notification) {}
    
	@objc internal func didReceiveProductCheckData(_ notification: Notification) {
		shouldUpdateProductCheckData(notification) { productWithPDCData in
			self.clientProduct = productWithPDCData
			showLoadingGif(false)
			setLoadingScreen(loading: true)
            isLoading = true
		}
	}

	@objc internal func didReceiveStoreProduct(_ notification: Notification) {
		shouldUpdateStoreProduct(notification) { storeProduct in
			self.serverProduct = storeProduct
		}
	}

	/// A parent function to set up InPage recommendation
	@objc internal func didReceiveSizeRecommendationData(_ notification: Notification) {
        isLoading = false
        isError = false
    }

	internal func shouldUpdateInPageRecommendation(
		_ notification: Notification,
		shouldUpdate: (Virtusize.SizeRecommendationData) -> Void
	) {
		guard let notificationData = notification.userInfo as? [String: Any],
			  let sizeRecData = notificationData[NotificationKey.sizeRecommendationData] as? Virtusize.SizeRecommendationData,
			  sizeRecData.serverProduct.externalId == self.clientProduct?.externalId else {
			return
		}
		shouldUpdate(sizeRecData)
	}

	internal func shouldShowInPageErrorScreen(
		_ notification: Notification,
		shouldShow: () -> Void
	) {
		guard let notificationData = notification.userInfo as? [String: Any],
			  let inPageError = notificationData[NotificationKey.inPageError] as? Virtusize.InPageError,
			  inPageError.externalProductId == self.clientProduct?.externalId else {
			return
		}
		shouldShow()
	}

	/// A parent function for showing the error screen
	@objc internal func didReceiveInPageError(_ notification: Notification) {
        isError = true
    }

	/// Sets up the styles for the loading screen and the screen after finishing loading
	///
	/// - Parameters:
	///   - loading: Pass true when it's loading, and pass false when finishing loading
	internal func setLoadingScreen(loading: Bool) {
        isError = false
    }

	internal func setup() {}

	internal func setHorizontalMargins(view: UIView, margin: CGFloat) {
		userSetMargin = margin
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
			product: clientProduct,
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

    public func userClosedWidget() {
        handleUserClosedWidget()
    }
    
    public func userClickedLanguage(language: VirtusizeLanguage) {
        handleUserClickedLanguage(language: language)
    }

	internal func setContentViewListener(listener: ((VirtusizeInPageView) -> Void)?) {
		contentViewListener = listener
	}
}
