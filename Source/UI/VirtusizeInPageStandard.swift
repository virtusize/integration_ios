//
//  VirtusizeInPageStandard.swift
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

// swiftlint:disable type_body_length
/// This class is the custom Virtusize InPage Standard view that can be added in the client's layout file.
public class VirtusizeInPageStandard: VirtusizeInPageView {

    /// The property to set the background color of the size check button
    public var inPageStandardButtonBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

	private var views: [String: UIView] = [:]
	private var metrics: [String: CGFloat] = [:]
    private let inPageStandardView: UIView = UIView()
	private let vsIconImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    private let userProductImageView: VirtusizeProductImageView = VirtusizeProductImageView(size: 40)
	private let storeProductImageView: VirtusizeProductImageView = VirtusizeProductImageView(size: 40)
    private let messageStackView: UIStackView = UIStackView()
    private let topMessageLabel: UILabel = UILabel()
    private let bottomMessageLabel: UILabel = UILabel()
    private let checkSizeButton: UIButton = UIButton()
    private let vsSignatureImageView: UIImageView = UIImageView()
    private let privacyPolicyLink: UILabel = UILabel()
    private let errorImageView: UIImageView = UIImageView()
    private let errorText: UILabel = UILabel()

    private var messageLineSpacing: CGFloat = 6
	private var userProductImageSize: CGFloat = 0
	private var productImageViewOffset: CGFloat = 0

	// Any iPhone screen is smaller than a iPhone 5, whose screen width is 414pt
	// And the default horizontal margin between the phone screen and InPage is 16pt
	private let smallInPageWidth: CGFloat = 414 - 16 * 2

	private var productImagesAreAnimating: Bool = false

	/// Once the store product image is set, set the value to true to avoid loading repetitively
	private var storeProductImageIsSet = false
	private var crossFadeInAnimator: UIViewPropertyAnimator?
	private var crossFadeOutAnimator: UIViewPropertyAnimator?

    public func setupHorizontalMargin(view: UIView, margin: CGFloat) {
        setHorizontalMargins(view: view, margin: margin)
    }

    internal override func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        inPageStandardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(clickInPageViewAction))
        )

        checkSizeButton.addTarget(self, action: #selector(clickInPageViewAction), for: .touchUpInside)

        privacyPolicyLink.isUserInteractionEnabled = true
        privacyPolicyLink.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicyLink))
        )
    }

    private func addSubviews() {
        addSubview(inPageStandardView)
        addSubview(vsSignatureImageView)
        addSubview(privacyPolicyLink)
		inPageStandardView.addSubview(userProductImageView)
        inPageStandardView.addSubview(storeProductImageView)
		inPageStandardView.addSubview(vsIconImageView)
        inPageStandardView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(topMessageLabel)
        messageStackView.addArrangedSubview(bottomMessageLabel)
        inPageStandardView.addSubview(checkSizeButton)
        inPageStandardView.addSubview(errorImageView)
        inPageStandardView.addSubview(errorText)
    }

    // swiftlint:disable function_body_length
    private func setConstraints() {
		translatesAutoresizingMaskIntoConstraints = false
        inPageStandardView.translatesAutoresizingMaskIntoConstraints = false
		vsIconImageView.translatesAutoresizingMaskIntoConstraints = false
        vsSignatureImageView.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyLink.translatesAutoresizingMaskIntoConstraints = false
		userProductImageView.translatesAutoresizingMaskIntoConstraints = false
        storeProductImageView.translatesAutoresizingMaskIntoConstraints = false
        messageStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        checkSizeButton.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorText.translatesAutoresizingMaskIntoConstraints = false

        views = [
            "inPageStandardView": inPageStandardView,
			"vsIconImageView": vsIconImageView,
            "virtusizeImageView": vsSignatureImageView,
            "privacyPolicyLink": privacyPolicyLink,
			"userProductImageView": userProductImageView,
            "storeProductImageView": storeProductImageView,
            "messageStackView": messageStackView,
            "topMessageLabel": topMessageLabel,
            "bottomMessageLabel": bottomMessageLabel,
            "checkSizeButton": checkSizeButton,
            "errorImageView": errorImageView,
            "errorText": errorText
        ]

	    metrics = [
			"defaultMargin": defaultMargin,
			"userProductImageSize": userProductImageSize,
			"productImageViewOffset": productImageViewOffset
        ]

        let inPageStandardViewHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[inPageStandardView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let inPageStandardViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[inPageStandardView]-10-[virtusizeImageView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let footerHorizontalConstraints = NSLayoutConstraint.constraints(
                   withVisualFormat: "H:|-0-[virtusizeImageView(>=10)]-(>=0)-[privacyPolicyLink(>=15)]-0-|",
                   options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                   metrics: nil,
                   views: views
        )

        let errorScreenVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-defaultMargin-[errorImageView(40)]-defaultMargin-[errorText]-defaultMargin-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let errorImageViewHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(>=defaultMargin)-[errorImageView(40)]-(>=defaultMargin)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let errorTextHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(>=defaultMargin)-[errorText]-(>=defaultMargin)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        // swiftlint:disable line_length
		let inPageStandardViewsHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-defaultMargin-[userProductImageView(==userProductImageSize)]-(productImageViewOffset)-[storeProductImageView(==40)]-defaultMargin-[messageStackView]-(>=defaultMargin)-[checkSizeButton]-defaultMargin-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

		let vsIconImageViewHorizontalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-14-[vsIconImageView]-(>=8)-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: metrics,
			views: views
		)

        let leftProductImageViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=14)-[userProductImageView(==40)]-(>=14)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

		let storeProductImageViewVerticalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-(>=14)-[storeProductImageView(==40)]-(>=14)-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: nil,
			views: views
		)

        let messageStackViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=14@700)-[messageStackView]-(>=14@700)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let checkSizeButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=20)-[checkSizeButton]-(>=20)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

		privacyPolicyLink.centerYAnchor.constraint(
			equalTo: vsSignatureImageView.centerYAnchor,
			constant: 0
		).isActive = true
		vsSignatureImageView.centerYAnchor.constraint(
			equalTo: privacyPolicyLink.centerYAnchor,
			constant: 0
		).isActive = true

        addConstraints(inPageStandardViewHorizontalConstraints)
        addConstraints(inPageStandardViewVerticalConstraints)
		addConstraints(vsIconImageViewHorizontalConstraints)
		addConstraints(inPageStandardViewsHorizontalConstraints)
        addConstraints(footerHorizontalConstraints)
        addConstraints(leftProductImageViewVerticalConstraints)
		addConstraints(storeProductImageViewVerticalConstraints)
        addConstraints(messageStackViewVerticalConstraints)
        addConstraints(checkSizeButtonVerticalConstraints)
        addConstraints(errorScreenVerticalConstraints)
        addConstraints(errorImageViewHorizontalConstraints)
        addConstraints(errorTextHorizontalConstraints)

		addConstraint(vsIconImageView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
		addConstraint(userProductImageView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(storeProductImageView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(messageStackView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(checkSizeButton.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(errorImageView.centerXAnchor.constraint(equalTo: inPageStandardView.centerXAnchor))
        addConstraint(errorText.centerXAnchor.constraint(equalTo: inPageStandardView.centerXAnchor))
    }

    // swiftlint:disable function_body_length
    private func setStyle() {
        inPageStandardView.backgroundColor = .white
        inPageStandardView.layer.masksToBounds = false
        inPageStandardView.layer.shadowColor = UIColor.vsInPageShadowColor.cgColor
        inPageStandardView.layer.shadowOpacity = 1
        inPageStandardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        inPageStandardView.layer.shadowRadius = 14

		vsIconImageView.image = Assets.icon

		userProductImageView.productImageType = .USER
		storeProductImageView.productImageType = .STORE

        vsSignatureImageView.image = Assets.vsSignature

        privacyPolicyLink.text = Localization.shared.localize("privacy_policy")
        privacyPolicyLink.textColor = .vsGray900Color
        privacyPolicyLink.setContentHuggingPriority(.required, for: .vertical)

        messageStackView.axis = .vertical
        messageStackView.distribution = .equalSpacing

        topMessageLabel.numberOfLines = 0
        topMessageLabel.textColor = .vsGray900Color
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.textColor = .vsGray900Color

        if inPageStandardButtonBackgroundColor != nil {
            checkSizeButton.backgroundColor = inPageStandardButtonBackgroundColor
        } else if style == .TEAL {
            checkSizeButton.backgroundColor = .vsTealColor
        } else {
            checkSizeButton.backgroundColor = .vsGray900Color
        }
        checkSizeButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 8, bottom: 6, right: 6)
        checkSizeButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        checkSizeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let rightArrowImageTemplate = Assets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        checkSizeButton.setImage(rightArrowImageTemplate, for: .normal)
        checkSizeButton.setImage(rightArrowImageTemplate, for: .highlighted)

        checkSizeButton.semanticContentAttribute = .forceRightToLeft
        checkSizeButton.imageView?.tintColor = UIColor.white

        errorImageView.image = Assets.errorHanger
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.isHidden = true

        errorText.numberOfLines = 0
        errorText.textColor = .vsGray700Color
        errorText.isHidden = true

        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            topMessageLabel.font = Font.proximaNova(size: 14)
            bottomMessageLabel.font = Font.proximaNova(size: 18, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.proximaNova(size: 14)
            privacyPolicyLink.font = Font.proximaNova(size: 12)
            errorText.font = Font.proximaNova(size: 12)
            messageLineSpacing = 2
        case .JAPANESE:
            topMessageLabel.font = Font.notoSansCJKJP(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKJP(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKJP(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKJP(size: 10)
            errorText.font = Font.notoSansCJKJP(size: 10)
            messageLineSpacing = 6
        case .KOREAN:
            topMessageLabel.font = Font.notoSansCJKKR(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKKR(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKKR(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKKR(size: 10)
            errorText.font = Font.notoSansCJKKR(size: 10)
            messageLineSpacing = 6
        default:
            break
        }
        checkSizeButton.layer.cornerRadius = checkSizeButton.intrinsicContentSize.height / 2
        messageStackView.spacing = messageLineSpacing
    }

    @objc private func openPrivacyPolicyLink() {
        if let sharedApplication = UIApplication.safeShared,
            let url = URL(string: Localization.shared.localize("privacy_policy_link")) {
            sharedApplication.safeOpenURL(url)
        }
    }

    public override func isLoading() {
        super.isLoading()
        setLoadingScreen(loading: true)
    }

	public override func setInPageRecommendation() {
		super.setInPageRecommendation()

		// Using DispatchSemaphore to execute synchronous tasks
		let semaphore = DispatchSemaphore(value: 0)

		let bestFitUserProduct = Virtusize.sizeComparisonRecommendedSize?.bestUserProduct
		DispatchQueue.global().async {
			// If item to item recommendation is available, display two user and store product images side by side
			if let bestFitUserProduct = Virtusize.sizeComparisonRecommendedSize?.bestUserProduct {
				self.loadAndSetUserProductImage(semaphore: semaphore, bestFitUserProduct: bestFitUserProduct)
				self.loadAndSetStoreProductImage(semaphore: semaphore)
				DispatchQueue.main.async {
					if self.inPageStandardView.frame.size.width >= self.smallInPageWidth {
						self.adjustProductImageViewPosition(userProductImageSize: 40, productImageViewOffset: -2)
					}
				}
			// Otherwise, only display the store product image and
			} else {
				self.loadAndSetStoreProductImage(semaphore: semaphore)
				DispatchQueue.main.async {
					if self.inPageStandardView.frame.size.width >= self.smallInPageWidth {
						self.adjustProductImageViewPosition(userProductImageSize: 0, productImageViewOffset: 0)
					}
				}
			}

			// If the width of the InPage standard view is small than the minimum InPage width
			DispatchQueue.main.async {
				if self.inPageStandardView.frame.size.width < self.smallInPageWidth {
					// if item to item recommendation is available, we make user and store product images fade in/out repeatedly
					if bestFitUserProduct != nil {
						if !self.productImagesAreAnimating {
							self.startCrossFadeProductImageViews()
						}
					// Otherwise, stop any fading animations
					} else {
						self.stopCrossFadeProductImageViews()
					}
				}

				self.setMessageLabelTexts(
					Virtusize.storeProduct!,
					Virtusize.i18nLocalization!,
					Virtusize.sizeComparisonRecommendedSize,
					Virtusize.bodyProfileRecommendedSize?.sizeName
				)

				self.setLoadingScreen(loading: false, bestFitUserProduct: bestFitUserProduct)
			}
		}
	}

	private func loadAndSetUserProductImage(semaphore: DispatchSemaphore, bestFitUserProduct: VirtusizeInternalProduct) {
		self.userProductImageView.setImage(product: bestFitUserProduct, localImageUrl: nil) {
			semaphore.signal()
		}
		semaphore.wait()
	}

	private func loadAndSetStoreProductImage(semaphore: DispatchSemaphore) {
		if !self.storeProductImageIsSet {
			self.storeProductImageView.setImage(product: Virtusize.storeProduct!, localImageUrl: Virtusize.product?.imageURL) {
				self.storeProductImageIsSet = true
				semaphore.signal()
			}
			semaphore.wait()
		}
	}

	private func adjustProductImageViewPosition(userProductImageSize: CGFloat, productImageViewOffset: CGFloat) {
		// Remove all the constraints
		self.removeConstraints(self.constraints)
		self.userProductImageSize = userProductImageSize
		self.productImageViewOffset = productImageViewOffset
		// Reset constraints
		self.setConstraints()
	}

	private func startCrossFadeProductImageViews() {
		productImagesAreAnimating = true
		if userProductImageView.alpha == 1.0 {
			fadeInAnimation(self.storeProductImageView, self.userProductImageView)
			fadeOutAnimation(self.userProductImageView)
		} else {
			fadeInAnimation(self.userProductImageView, self.storeProductImageView)
			fadeOutAnimation(self.storeProductImageView)
		}
	}

	/// Fades in an image
	///
	/// - Parameters:
	///   - productImageOne: The image to be faded in
	///   - productImageTwo: The image to be set invisible after the animation is done
	private func fadeInAnimation(
		_ productImageOne: VirtusizeProductImageView,
		_ productImageTwo: VirtusizeProductImageView
	) {
		productImageOne.alpha = 0.0
		crossFadeInAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 2.5, options: [.curveEaseIn], animations: {
			productImageOne.alpha = 1.0
		})
		crossFadeInAnimator?.startAnimation()
	}

	/// Fades out an image
	///
	/// - Parameter productImage: The image to be faded out
	private func fadeOutAnimation(_ productImage: VirtusizeProductImageView) {
		productImage.alpha = 1.0
		crossFadeOutAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 2.5, options: [.curveEaseOut], animations: {
			productImage.alpha = 0.0
		}, completion: { _ in
			self.startCrossFadeProductImageViews()
		})
		crossFadeOutAnimator?.startAnimation()
	}

	/// Stops the cross fade animation
	private func stopCrossFadeProductImageViews() {
		DispatchQueue.main.async {
			self.crossFadeInAnimator?.stopAnimation(true)
			self.crossFadeOutAnimator?.stopAnimation(true)
			self.userProductImageView.alpha = 1.0
			self.storeProductImageView.alpha = 1.0
			self.productImagesAreAnimating = false
		}
	}

	private func setMessageLabelTexts(
		_ storeProduct: VirtusizeInternalProduct,
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?
	) {
        let trimType = VirtusizeI18nLocalization.TrimType.MULTIPLELINES
		let recommendationText = storeProduct.getRecommendationText(
			i18nLocalization,
			sizeComparisonRecommendedSize,
			bodyProfileRecommendedSizeName,
			trimType
		)
        let recommendationTextArray = recommendationText.components(separatedBy: trimType.rawValue)
        if recommendationTextArray.count == 2 {
            self.topMessageLabel.attributedText = NSAttributedString(
                string: recommendationTextArray[0]
            ).lineSpacing(self.messageLineSpacing)
            self.bottomMessageLabel.attributedText = NSAttributedString(
                string: recommendationTextArray[1]
            ).lineSpacing(self.messageLineSpacing)
        } else {
            self.topMessageLabel.isHidden = true
			self.topMessageLabel.text = ""
            self.bottomMessageLabel.attributedText = NSAttributedString(
                string: recommendationText
            ).lineSpacing(self.messageLineSpacing)
        }
    }

	/// Sets up the styles for the loading screen and the screen after finishing loading
	///
	/// - Parameters:
	///   - loading: Pass true when it's loading, and pass false when finishing loading
	///   - userBestFitProduct: Pass the user best fit product to determine whether to display the user product image or not
	private func setLoadingScreen(loading: Bool, bestFitUserProduct: VirtusizeInternalProduct? = nil) {
        vsSignatureImageView.isHidden = loading ? true : false
        privacyPolicyLink.isHidden = loading ? true : false
        topMessageLabel.isHidden = loading ? true : false
		vsIconImageView.isHidden = loading ? false : true
		userProductImageView.isHidden = (loading || bestFitUserProduct == nil) ? true : false
		storeProductImageView.isHidden = loading ? true : false
        if loading {
            startLoadingTextAnimation(
                label: bottomMessageLabel,
                text: Localization.shared.localize("inpage_loading_text")
            )
        } else {
            stopLoadingTextAnimation()
        }
    }

	internal override func showErrorScreen() {
        inPageStandardView.layer.shadowOpacity = 0
        inPageStandardView.isUserInteractionEnabled = false
		vsIconImageView.isHidden = true
		userProductImageView.isHidden = true
        storeProductImageView.isHidden = true
        bottomMessageLabel.isHidden = true
        checkSizeButton.isHidden = true
        errorImageView.isHidden = false
        errorText.isHidden = false
        errorText.attributedText = NSAttributedString(
            string: Localization.shared.localize("inpage_error_long_text")
        ).lineSpacing(self.messageLineSpacing)
        errorText.textAlignment = .center
    }
}
