//
//  VirtusizeButton.swift
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

import UIKit
import VirtusizeUIKit

/// This class is the custom Virtusize button that is added in the client's layout file.
public class VirtusizeButton: UIButton, VirtusizeView, VirtusizeViewEventProtocol {
	public var presentingViewController: UIViewController?
	public var messageHandler: VirtusizeMessageHandler?
	public var clientProduct: VirtusizeProduct?
	public var serverProduct: VirtusizeServerProduct?

	public var virtusizeEventHandler: VirtusizeEventHandler?

	override public var isHighlighted: Bool {
		didSet {
			if style == .BLACK {
				backgroundColor = isHighlighted ? .vsGray900PressedColor : .vsGray900Color
			} else if style == .TEAL {
				backgroundColor = isHighlighted ? .vsTealPressedColor : .vsTealColor
			}
		}
	}

	/// The property to set the Virtusize view style that this SDK provides
	public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
		didSet {
			setStyle()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		virtusizeEventHandler = self
		isHidden = true
		addNotificationObserver()
	}

	public init(uiView: UIView? = nil) {
		super.init(frame: .zero)
        if uiView != nil {
            addSubview(uiView!)
        }
		virtusizeEventHandler = self
		isHidden = true
		setStyle()
		addNotificationObserver()
	}

	/// Add observers to listen to notification data from the sender (Virtusize.self)
	private func addNotificationObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveProductDataCheck(_:)),
			name: .productDataCheck,
			object: Virtusize.self
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveStoreProduct(_:)),
			name: .storeProduct,
			object: Virtusize.self
		)
	}

	@objc func didReceiveProductDataCheck(_ notification: Notification) {
		shouldUpdateProductDataCheckData(notification) { productWithPDCData in
			self.clientProduct = productWithPDCData
			isHidden = false
		}
	}

	@objc func didReceiveStoreProduct(_ notification: Notification) {
		shouldUpdateStoreProduct(notification) { storeProduct in
			self.serverProduct = storeProduct
		}
	}

	public func isLoading() {
		isHidden = false
	}

	/// Set up the style of `VirtusizeButton`
	private func setStyle() {
		if style == .NONE {
			setTitle(Localization.shared.localize("check_size"), for: .normal)
			setTitleColor(.vsGray900Color, for: .normal)
			setTitleColor(.vsGray900PressedColor, for: .highlighted)
			return
		}

		if style == .BLACK {
			backgroundColor = .vsGray900Color
		} else if style == .TEAL {
			backgroundColor = .vsTealColor
		}

		setTitle(Localization.shared.localize("check_size"), for: .normal)
		setTitleColor(.white, for: .normal)
		setTitleColor(.white, for: .highlighted)
		tintColor = .white
		layer.cornerRadius = 20
		titleLabel?.font = .systemFont(ofSize: 12)

		contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

		setImage(VirtusizeAssets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
		setImage(VirtusizeAssets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .highlighted)

		addTarget(self, action: #selector(clickButtonAction), for: .touchUpInside)
	}

	@objc private func clickButtonAction() {
		openVirtusizeWebView(
			product: clientProduct,
			serverProduct: serverProduct,
			eventHandler: virtusizeEventHandler
		)
	}

	public func setVirtusizeEventHandler() {
		Virtusize.virtusizeEventHandler = self
	}
}

extension VirtusizeButton: VirtusizeEventHandler {

	public func userOpenedWidget() {
		print("userOpenedWidget")
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
