//
//  VirtusizeInPageMini.swift
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

/// This class is the custom Virtusize InPage Mini view that can be added in the client's layout file.
public class VirtusizeInPageMini: VirtusizeInPageView {

	/// The property to set the background color of the InPage Mini view
	public var inPageMiniBackgroundColor: UIColor? {
		didSet {
			setStyle()
		}
	}

	/// The property to set the font size of the size check button
	public var buttonFontSize: CGFloat? {
		didSet {
			setStyle()
		}
	}

	/// The property to set the font size of the message
	public var messageFontSize: CGFloat? {
		didSet {
			setStyle()
		}
	}

	public override var intrinsicContentSize: CGSize {
		var size = bounds.size
		size.height = inPageMiniMessageLabel.intrinsicContentSize.height + 2 * verticalMargin
		return size
	}

	private let messageAndButtonMargin: CGFloat = 8
	private let verticalMargin: CGFloat = 5

    private let inPageMiniImageView: UIImageView = UIImageView()
	internal let inPageMiniMessageLabel: UILabel = UILabel()
    internal let inPageMiniSizeCheckButton: UIButton = UIButton()

    internal override func setup() {
        addSubviews()
        setConstraints()
        setStyle()

		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickInPageViewAction)))
		inPageMiniSizeCheckButton.addTarget(self, action: #selector(clickInPageViewAction), for: .touchUpInside)
	}

	internal override func didReceiveSizeRecommendationData(_ notification: Notification) {
		shouldUpdateInPageRecommendation(notification) { sizeRecData in
			serverProduct = sizeRecData.serverProduct

			setLoadingScreen(loading: false)
			inPageMiniMessageLabel.attributedText = NSAttributedString(
				string:
					sizeRecData.serverProduct.getRecommendationText(
						VirtusizeRepository.shared.i18nLocalization!,
						sizeRecData.sizeComparisonRecommendedSize,
						sizeRecData.bodyProfileRecommendedSize?.sizeName,
						VirtusizeI18nLocalization.TrimType.ONELINE
					)
			).lineSpacing(self.verticalMargin/2)
		}
	}

	internal override func didReceiveInPageError(_ notification: Notification) {
		shouldShowInPageErrorScreen(notification) {
			backgroundColor = .white
			stopLoadingTextAnimation()
			inPageMiniImageView.image = VirtusizeAssets.errorHanger
			inPageMiniMessageLabel.textColor = .vsGray700Color
			inPageMiniMessageLabel.text = Localization.shared.localize("inpage_error_short_text")
			inPageMiniSizeCheckButton.isHidden = true
			inPageMiniSizeCheckButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
			setupTextsStyle(messageLabelIsBold: false)
			isUserInteractionEnabled = false
		}
	}

	private func addSubviews() {
		addSubview(inPageMiniImageView)
		addSubview(inPageMiniMessageLabel)
		addSubview(inPageMiniSizeCheckButton)
	}

	private func setConstraints() {
		inPageMiniImageView.translatesAutoresizingMaskIntoConstraints = false
		inPageMiniMessageLabel.translatesAutoresizingMaskIntoConstraints = false
		inPageMiniSizeCheckButton.translatesAutoresizingMaskIntoConstraints = false

		let views = [
			"inPageMiniImageView": inPageMiniImageView,
			"messageLabel": inPageMiniMessageLabel,
			"sizeCheckButton": inPageMiniSizeCheckButton
		]
		let metrics = [
			"horizontalMargin": defaultMargin,
			"verticalMargin": verticalMargin,
			"messageAndButtonMargin": messageAndButtonMargin
		]

		// swiftlint:disable line_length
		let horizontalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-horizontalMargin-[inPageMiniImageView]-0-[messageLabel]-(>=messageAndButtonMargin)-[sizeCheckButton]-horizontalMargin-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: metrics,
			views: views
		)

		let inPageMiniImageViewVerticalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-(>=verticalMargin)-[inPageMiniImageView(18)]-(>=verticalMargin)-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: metrics,
			views: views
		)

		let messageLabelVerticalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-verticalMargin-[messageLabel]-verticalMargin-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: metrics,
			views: views
		)

		let sizeCheckButtonVerticalConstraints = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-(>=verticalMargin)-[sizeCheckButton]-(>=verticalMargin)-|",
			options: NSLayoutConstraint.FormatOptions(rawValue: 0),
			metrics: metrics,
			views: views
		)

		addConstraints(horizontalConstraints)
		addConstraints(inPageMiniImageViewVerticalConstraints)
		addConstraints(messageLabelVerticalConstraints)
		addConstraints(sizeCheckButtonVerticalConstraints)
		addConstraint(inPageMiniImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor))
		addConstraint(inPageMiniSizeCheckButton.centerYAnchor.constraint(equalTo: self.centerYAnchor))
	}

	private func setStyle() {
		inPageMiniImageView.contentMode = .scaleAspectFit

		inPageMiniMessageLabel.numberOfLines = 0
		inPageMiniMessageLabel.setContentHuggingPriority(.required, for: .horizontal)
		inPageMiniSizeCheckButton.backgroundColor = UIColor.white
		inPageMiniSizeCheckButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
		inPageMiniSizeCheckButton.setTitle(Localization.shared.localize("check_size"), for: .normal)

		inPageMiniSizeCheckButton.layer.cornerRadius = inPageMiniSizeCheckButton.intrinsicContentSize.height / 2

		let rightArrowImageTemplate = VirtusizeAssets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		inPageMiniSizeCheckButton.setImage(rightArrowImageTemplate, for: .normal)
		inPageMiniSizeCheckButton.setImage(rightArrowImageTemplate, for: .highlighted)
		inPageMiniSizeCheckButton.semanticContentAttribute = .forceRightToLeft
		if inPageMiniBackgroundColor != nil {
			inPageMiniSizeCheckButton.setTitleColor(inPageMiniBackgroundColor, for: .normal)
			inPageMiniSizeCheckButton.imageView?.tintColor = inPageMiniBackgroundColor
		} else if style == .TEAL {
			inPageMiniSizeCheckButton.setTitleColor(.vsTealColor, for: .normal)
			inPageMiniSizeCheckButton.imageView?.tintColor = .vsTealColor
		} else {
			inPageMiniSizeCheckButton.setTitleColor(.vsGray900Color, for: .normal)
			inPageMiniSizeCheckButton.imageView?.tintColor = .vsGray900Color
		}
		inPageMiniSizeCheckButton.setContentCompressionResistancePriority(.required, for: .horizontal)
	}

	private func getBackgroundColor() -> UIColor {
		if inPageMiniBackgroundColor != nil {
			return inPageMiniBackgroundColor!
		} else if style == .TEAL {
			return .vsTealColor
		} else {
			return .vsGray900Color
		}
	}

	private func setupTextsStyle(messageLabelIsBold: Bool = false) {
		let displayLanguage = Virtusize.params?.language
		let messageTextSize = messageFontSize ?? 12
		let buttonTextSize = buttonFontSize ?? 10
		switch displayLanguage {
			// swiftlint:disable switch_case_alignment
			case .ENGLISH:
				inPageMiniMessageLabel.font = Font.system(size: messageTextSize + 2, weight: messageLabelIsBold ? .bold : .regular)
				inPageMiniSizeCheckButton.titleLabel?.font = Font.system(size: buttonTextSize + 2)
			case .JAPANESE:
				inPageMiniMessageLabel.font = Font.notoSansCJKJP(size: messageTextSize, weight: messageLabelIsBold ? .bold : .regular)
				inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKJP(size: buttonTextSize)
			case .KOREAN:
				inPageMiniMessageLabel.font = Font.notoSansCJKKR(size: messageTextSize, weight: messageLabelIsBold ? .bold : .regular)
				inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKKR(size: buttonTextSize)
			default:
				inPageMiniMessageLabel.font = Font.system(size: messageTextSize + 2, weight: messageLabelIsBold ? .bold : .regular)
				inPageMiniSizeCheckButton.titleLabel?.font = Font.system(size: buttonTextSize + 2)
		}
	}

	internal override func setLoadingScreen(loading: Bool) {
        backgroundColor = loading ? .white : getBackgroundColor()
        inPageMiniImageView.image = loading ? VirtusizeAssets.icon : nil
        inPageMiniMessageLabel.textColor = loading ? .vsGray900Color : .white
        setupTextsStyle(messageLabelIsBold: loading)
		if loading {
			startLoadingTextAnimation(
				label: inPageMiniMessageLabel,
				text: Localization.shared.localize("inpage_loading_text")
			)
		} else {
			stopLoadingTextAnimation()
		}
        inPageMiniSizeCheckButton.isHidden = loading ? true: false
		DispatchQueue.main.async {
			self.contentViewListener?(self)
		}
    }
}
