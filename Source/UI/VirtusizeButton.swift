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

/// This class is the custom Virtusize button that is added in the client's layout file.
public class VirtusizeButton: UIButton, VirtusizeView, VirtusizeViewEventProtocol {
	public var presentingViewController: UIViewController?
	public var messageHandler: VirtusizeMessageHandler?
	public var product: VirtusizeProduct?
	public var serverProduct: VirtusizeServerProduct?

	internal var virtusizeEventHandler: VirtusizeEventHandler?

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
	}

	public init() {
		super.init(frame: .zero)
		virtusizeEventHandler = self
		isHidden = true
		setStyle()
	}
	
	deinit {
		print("VirtusizeButton is dying!")
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

	public func onProductDataCheck(product: VirtusizeProduct) {
		guard self.product?.externalId == product.externalId else {
			return
		}
		isHidden = false
	}

	public func onStoreProduct(product: VirtusizeServerProduct) {
		guard self.product?.externalId == product.externalId else {
			return
		}
		self.serverProduct = product
	}

	@objc private func clickButtonAction() {
		VirtusizeRepository.shared.lastProductOnVirtusizeWebView = self.serverProduct
		openVirtusizeWebView(
			product: self.product,
			eventHandler: self
		)
	}
}

extension VirtusizeButton: VirtusizeEventHandler {

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
