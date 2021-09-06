//
//  VirtusizeUIBaseButton.swift
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

public class VirtusizeUIBaseButton: UIButton {
	public var style = VirtusizeUIButtonStyle.default {
		didSet {
			setStyle()
		}
	}

	internal let rippleView = UIView()
	internal var rippleShapeLayer: CAShapeLayer?
	internal var rippleMask: CAShapeLayer {
		let maskLayer = CAShapeLayer()
		maskLayer.path = UIBezierPath(
			roundedRect: bounds,
			cornerRadius: layer.cornerRadius
		).cgPath
		return maskLayer
	}
	internal var startTouchLocation: CGPoint?
	private var _backgroundColor: UIColor?

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

		rippleShapeLayerAnimation(holdAnimation: holdAnimation)
	}

	private func rippleShapeLayerAnimation(holdAnimation: Bool) {
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

	func setup() {
		addRippleView()
		setStyle()
	}

	private func addRippleView() {
		rippleView.frame = bounds
		rippleView.alpha = 0
		addSubview(rippleView)
	}

	func setStyle() {
		if !isEnabled {
			setBackgroundColor(color: .vsGray300Color)
			hideBorder()
			hideShadow()
			setTitleColor(.vsGray700Color, for: .normal)
		} else {
			if style == .inverted {
				setBackgroundColor(color: .vsGray900Color)
				hideBorder()
				setShadow()
			} else if style == .flat {
				setBackgroundColor(color: .white)
				setBorder()
				hideShadow()
			} else if isCustomBackgroundColor {
				hideBorder()
				setShadow()
			} else if style == .default {
				setBackgroundColor(color: .white)
				hideBorder()
				setShadow()
			}
			setTitleColor(backgroundColor == .white ? .vsGray900Color : .white, for: .normal)
		}

		rippleView.backgroundColor = backgroundColor

		setButtonSize()
	}

	private func setBackgroundColor(color: UIColor) {
		guard backgroundColor != color else {
			return
		}
		backgroundColor = color
	}

	private var isCustomBackgroundColor: Bool {
		return backgroundColor != nil && (((style == .default || style == .flat) && backgroundColor != .white) ||
			(style == .inverted && backgroundColor != .vsGray900Color))
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

	private func setBorder() {
		layer.borderColor = UIColor.vsGray300Color.cgColor
		layer.borderWidth = 1
	}

	private func hideBorder() {
		layer.borderWidth = 0
	}

	func setButtonSize() {}
}
