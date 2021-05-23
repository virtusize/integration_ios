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

public class VirtusizeInPageView: UIView, VirtusizeView {
	internal var virtusizeEventHandler: VirtusizeEventHandler?

    /// The property to set the Virtusize view style that this SDK provides
    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
            setup()
        }
    }

	public var memoryAddress: String {
		String(format: "%p", self)
	}
    public var presentingViewController: UIViewController?
    public var messageHandler: VirtusizeMessageHandler?
	public var isDeallocated: Bool?

    internal let defaultMargin: CGFloat = 8

    internal var loadingTextTimer: Timer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
		virtusizeEventHandler = self
        isHidden = true
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: .zero)
		virtusizeEventHandler = self
        isHidden = true
        setup()
    }

	public override func willMove(toWindow: UIWindow?) {
		// will dismiss a view controller, which is not a VirtusizeWebViewController
		if toWindow == nil {
			if !isVirtusizeWebViewControllerOnTopOfScreen() {
				isDeallocated = true
				Virtusize.activeVirtusizeViews = Virtusize.virtusizeViews
					.filter {
						$0.isDeallocated != true
					}
			}
		// will present an existing view controller
		} else {
			isDeallocated = false
		}
		VirtusizeRepository.shared.updateCurrentProductBy(
			viewId: Virtusize.activeVirtusizeViews.first?.memoryAddress
		)
	}

    public func isLoading() {
        isHidden = false
	}

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
		openVirtusizeWebView(eventHandler: virtusizeEventHandler)
    }

	/// A parent function to set up InPage recommendation
	internal func setInPageRecommendation(
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSize: BodyProfileRecommendedSize?
	) {}

	/// A parent function for showing the error screen
	internal func showErrorScreen() {}

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
		VirtusizeRepository.shared.fetchDataForInPageRecommendation(shouldUpdateUserProducts: false)
	}

	public func userAuthData(bid: String?, auth: String?) {
		VirtusizeRepository.shared.updateUserAuthData(bid: bid, auth: auth)
	}

	public func userSelectedProduct(userProductId: Int?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: false,
				selectedUserProductId: userProductId
			)
			VirtusizeRepository.shared.switchInPageRecommendation(.compareProduct)
		}
	}

	public func userAddedProduct(userProductId: Int?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(
				shouldUpdateUserProducts: true,
				selectedUserProductId: userProductId
			)
			VirtusizeRepository.shared.switchInPageRecommendation(.compareProduct)
		}
	}

	public func userChangedRecommendationType(changedType: SizeRecommendationType?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.switchInPageRecommendation(changedType)
		}
	}

	public func userUpdatedBodyMeasurements(recommendedSize: String?) {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.updateUserBodyRecommendedSize(recommendedSize)
			VirtusizeRepository.shared.switchInPageRecommendation(.body)
		}
	}

	public func userLoggedIn() {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.updateUserSession()
			VirtusizeRepository.shared.fetchDataForInPageRecommendation()
			VirtusizeRepository.shared.switchInPageRecommendation()
		}
	}

	public func clearUserData() {
		Virtusize.dispatchQueue.async {
			VirtusizeRepository.shared.clearUserData()
			VirtusizeRepository.shared.updateUserSession()
			VirtusizeRepository.shared.fetchDataForInPageRecommendation(shouldUpdateUserProducts: false)
			VirtusizeRepository.shared.switchInPageRecommendation()
		}
	}
}
