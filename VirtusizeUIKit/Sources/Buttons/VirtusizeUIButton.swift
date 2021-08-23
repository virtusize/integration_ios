//
//  VirtusizeUIButton.swift
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

public class VirtusizeUIButton: UIButton {

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

	public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)

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
		rippleShapeLayer!.fillColor = backgroundColor?.darker(by: 10)?.cgColor
		rippleShapeLayer!.position =  CGPoint(x: touchLocation.x, y: touchLocation.y)
		rippleShapeLayer!.opacity = 0

		rippleView.layer.addSublayer(rippleShapeLayer!)

		if holdAnimation {
			// From
			rippleShapeLayer!.transform = CATransform3DMakeScale(0, 0, 0)
			rippleShapeLayer!.opacity = 1.0

			// To
			CATransaction.begin()
			CATransaction.setAnimationDuration(0.7)
			rippleShapeLayer!.opacity = 0.5

			CATransaction.begin()
			CATransaction.setAnimationDuration(0.7)
			rippleShapeLayer!.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
			CATransaction.commit()

			CATransaction.commit()
		} else {
			let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
			scaleAnimation.fromValue = 0.5
			scaleAnimation.toValue = 1.5

			let opacityAnimation = CABasicAnimation(keyPath: "opacity")
			opacityAnimation.fromValue = 0.5
			opacityAnimation.toValue = 0.0

			let animationGroup = CAAnimationGroup()
			animationGroup.animations = [scaleAnimation, opacityAnimation]
			animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
			animationGroup.duration = CFTimeInterval(0.7)
			animationGroup.repeatCount = 1
			animationGroup.isRemovedOnCompletion = true

			rippleShapeLayer!.add(animationGroup, forKey: "rippleEffect")
		}
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

		rippleView.frame = bounds
		rippleView.layer.mask = rippleMask
	}

	func setup() {
		backgroundColor = .white

		setRippleView()
		setButtonShadow()

		contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
		layer.cornerRadius = intrinsicContentSize.height / 2

		setTitle("Default Button", for: .normal)
		setTitleColor(backgroundColor == .white ? .vsGray900Color : .white, for: .normal)
		titleLabel?.font = VirtusizeTypography().boldFont
	}

	private func setRippleView() {
		rippleView.backgroundColor = backgroundColor
		rippleView.frame = bounds
		rippleView.alpha = 0
		addSubview(rippleView)
	}

	private func setButtonShadow() {
		layer.shadowColor = UIColor.vsShadowColor.cgColor
		layer.shadowOpacity = 1
		layer.shadowOffset = CGSize(width: 0, height: 4)
		layer.shadowRadius = 12
	}
}
