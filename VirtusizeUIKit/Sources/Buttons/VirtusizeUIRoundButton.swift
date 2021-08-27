//
//  VirtusizeUIRoundButton.swift
//  VirtusizeUIKit
//
//  Copyright (c) 2021 Virtusize KK
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
import Foundation

public class VirtusizeUIRoundButton: UIButton {
	struct Constant {
		static let size = CGFloat(40)
		static let padding = CGFloat(8)
		static let maxImageSize = CGFloat(size - 2 * padding)
	}

	public var style = VirtusizeUIButtonStyle.default {
		didSet {
			setStyle()
		}
	}

	public var size = VirtusizeUIButtonSize.large {
		didSet {
			setStyle()
		}
	}

	public override var isEnabled: Bool {
		didSet {
			setStyle()
		}
	}

	public override var backgroundColor: UIColor? {
		didSet {
			setStyle()
		}
	}

	private let rippleView = UIView()
	private var rippleShapeLayer: CAShapeLayer?
	private var rippleMask: CAShapeLayer {
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(
			roundedRect: bounds,
			cornerRadius: layer.cornerRadius
		).cgPath
		return maskLayer
	}

	private var startTouchLocation: CGPoint?

	public init() {
		super.init(frame: .zero)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		startTouchLocation = touch.location(in: self)

		setRippleLayer(touchLocation: startTouchLocation!, holdAnimation: true)

		UIView.animate(
			withDuration: 0.1,
			delay: 0,
			options: UIView.AnimationOptions.allowUserInteraction,
			animations: {
				self.rippleView.alpha = 1
			},
			completion: nil
		)

		return super.beginTracking(touch, with: event)
	}

	public override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		releaseAnimation()
	}

	public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		releaseAnimation()
	}

	private func releaseAnimation() {
		setRippleLayer(touchLocation: startTouchLocation!, holdAnimation: false)

		UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
			self.rippleView.alpha = 1
		}, completion: { _ in
			UIView.animate(withDuration: 0.6, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
				self.rippleView.alpha = 0
			}, completion: nil)
		})
	}

	private func setRippleLayer(touchLocation: CGPoint, holdAnimation: Bool) {
		if rippleShapeLayer != nil {
			rippleShapeLayer?.removeFromSuperlayer()
			rippleShapeLayer = nil
		}
		rippleShapeLayer = CAShapeLayer()
		let maxBoundSize = max(bounds.size.width, bounds.size.height)
		rippleShapeLayer!.bounds = CGRect(x: 0, y: 0, width: maxBoundSize, height: maxBoundSize)
		rippleShapeLayer!.cornerRadius = maxBoundSize / 2
		rippleShapeLayer!.path = UIBezierPath(
			ovalIn: CGRect(x: 0, y: 0, width: maxBoundSize, height: maxBoundSize)
		).cgPath
		if backgroundColor?.isBright == true {
			rippleShapeLayer!.fillColor = backgroundColor?.darker(by: 10)?.cgColor
		} else {
			rippleShapeLayer!.fillColor =  backgroundColor?.lighter(by: 20)?.cgColor
		}
		rippleShapeLayer!.position =  CGPoint(x: touchLocation.x, y: touchLocation.y)
		rippleShapeLayer!.opacity = 0

		rippleView.layer.addSublayer(rippleShapeLayer!)

		if holdAnimation {
			let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
			scaleAnimation.fromValue = 0.0
			scaleAnimation.toValue = 0.65

			let opacityAnimation = CABasicAnimation(keyPath: "opacity")
			opacityAnimation.fromValue = 0.0
			opacityAnimation.toValue = 1.0

			let animationGroup = CAAnimationGroup()
			animationGroup.animations = [scaleAnimation, opacityAnimation]
			animationGroup.fillMode = CAMediaTimingFillMode.forwards
			animationGroup.duration = CFTimeInterval(0.3)
			animationGroup.isRemovedOnCompletion = false

			rippleShapeLayer!.add(animationGroup, forKey: "holdRippleEffect")
		} else {
			let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
			scaleAnimation.fromValue = 0.65
			scaleAnimation.toValue = 1.5

			let opacityAnimation = CABasicAnimation(keyPath: "opacity")
			opacityAnimation.fromValue = 1.0
			opacityAnimation.toValue = 0.0

			let animationGroup = CAAnimationGroup()
			animationGroup.animations = [scaleAnimation, opacityAnimation]
			animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
			animationGroup.duration = CFTimeInterval(0.7)
			animationGroup.repeatCount = 1
			animationGroup.isRemovedOnCompletion = true

			rippleShapeLayer!.add(animationGroup, forKey: "releaseRippleEffect")
		}
	}

	private func setup() {
		addRippleView()
		addImage(VirtusizeAssets.searchProduct)
		setStyle()
	}

	private func addImage(_ image: UIImage?) {
		guard let image = image else {
			return
		}
		var resizeImage = image
		if image.size.width > image.size.height {
			let originWidth = image.size.width
			resizeImage = image.resize(
				to: CGSize(width: Constant.maxImageSize, height: image.size.height * Constant.maxImageSize / originWidth)
			)
		} else {
			let originHeight = image.size.height
			resizeImage = image.resize(
				to: CGSize(width: image.size.width * Constant.maxImageSize / originHeight, height: Constant.maxImageSize)
			)
		}
		print(resizeImage.size)
		setImage(resizeImage.withAlpha(0), for: .normal)
		let imageView = UIImageView(image: image)
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	private func setStyle() {
		if !isEnabled {
			backgroundColor = .vsGray300Color
			hideShadow()
			setTitleColor(.vsGray700Color, for: .normal)
		} else {
			if backgroundColor != nil {
				setShadow()
			} else if style == .default {
				backgroundColor = .white
				setShadow()
			} else if style == .inverted {
				backgroundColor = .vsGray900Color
				setShadow()
			} else if style == .flat {
				backgroundColor = .white
				hideShadow()
			}
			setTitleColor(backgroundColor == .white ? .vsGray900Color : .white, for: .normal)
		}

		rippleView.backgroundColor = backgroundColor

		setButtonSize()
	}

	private func addRippleView() {
		rippleView.frame = bounds
		rippleView.alpha = 0
		addSubview(rippleView)
	}

	private func setShadow() {
		layer.shadowColor = UIColor.vsShadowColor.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 4)
		layer.shadowRadius = 12
		layer.shadowOpacity = 1
	}

	private func hideShadow() {
		layer.shadowOpacity = 0
	}

	private func setButtonSize() {
		let typography = VirtusizeTypography()
		titleLabel?.font = typography.normalBoldFont
		contentEdgeInsets = UIEdgeInsets(
			top: Constant.padding,
			left: Constant.padding,
			bottom: Constant.padding,
			right: Constant.padding
		)
		layer.cornerRadius = Constant.size / 2
	}

}
