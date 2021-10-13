//
//  VirtusizeUINotification.swift
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

public class VirtusizeUINotification: UIView {

	public var autoClose = true
	public var autoCloseDelay = 2.0

	private var statusBarView: UIView!
	private var contentView: UIView!
	private var notificationImageView: UIImageView!
	private var titleLabel: UILabel!
	private var closeImageView: UIImageView!

	private var isDisplaying = false

	private struct Constants {
		static let contentPadding = CGFloat(10)
		static let notificationImageViewSize = CGFloat(24)
		static let closeImageViewSize = CGFloat(16)
		static let frameAnimationDuration = 0.2
	}

	private var appWindow: UIWindow? {
		return UIApplication.safeShared?.windows.first { $0.isKeyWindow }
	}
	
	private var statusBarHeight: CGFloat {
		UIApplication.safeShared?.statusBarFrame.height ?? 0
	}

	private var notificationHeight: CGFloat {
		return titleLabel.intrinsicContentSize.height + Constants.contentPadding * 2
	}

	private enum NotificationFrameStatus {
		case start, end
	}

	public init (
		title: String,
		style: VirtusizeUINotificationStyle = .info
	) {
		super.init(frame: .zero)

		backgroundColor = .white
		setNotificationShadow()

		contentView = UIView()
		addSubview(contentView)

		setNotificationImageView(style: style)
		setCloseImageView()
		setTitle(title)
	}

	private func setNotificationShadow() {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.vsShadowColor.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 4)
		layer.shadowRadius = 16
		layer.shadowOpacity = 1
	}

	@available(*, unavailable)
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented. Use init(title:, style:) instead.")
	}

	private func setNotificationImageView(style: VirtusizeUINotificationStyle) {
		notificationImageView = UIImageView(image: style.icon)

		contentView.addSubview(notificationImageView)

		notificationImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			notificationImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			notificationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
			notificationImageView.widthAnchor.constraint(equalToConstant: Constants.notificationImageViewSize),
			notificationImageView.heightAnchor.constraint(equalToConstant: Constants.notificationImageViewSize)
		])
	}

	private func setCloseImageView() {
		closeImageView = UIImageView(image: VirtusizeAssets.closeBlack)
		closeImageView.image = closeImageView.image?.withPadding(inset: 3)

		contentView.addSubview(closeImageView)

		closeImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			closeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			closeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
			closeImageView.widthAnchor.constraint(equalToConstant: Constants.closeImageViewSize),
			closeImageView.heightAnchor.constraint(equalToConstant: Constants.closeImageViewSize)
		])
	}

	private func setTitle(_ title: String) {
		titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.numberOfLines = 0

		titleLabel.textColor = .vsGray900Color
		titleLabel.font = VirtusizeTypography().smallFont

		contentView.addSubview(titleLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			titleLabel.leadingAnchor.constraint(equalTo: notificationImageView.trailingAnchor, constant: 10),
			titleLabel.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -10)
		])
	}

	public func show() {
		guard !isDisplaying else { return }

		setConstraintsForContentView()

		appWindow?.addSubview(self)

		isDisplaying = true

		setFrame(.start)
		setSubviewsVisibilities(isHidden: true)

		UIView.animate(
			withDuration: Constants.frameAnimationDuration,
			delay: 0.0,
			options: [.curveLinear],
			animations: {
				self.setFrame(.end)
			},
			completion: { completed in
				if completed {
					self.setSubviewsVisibilities(isHidden: false)
					if self.autoClose {
						self.perform(
							#selector(self.dismiss),
							with: nil,
							afterDelay: self.autoCloseDelay
						)
					}
				}
			}
		)
	}

	@objc public func dismiss() {
		guard isDisplaying else { return }

		isDisplaying = false
		setSubviewsVisibilities(isHidden: true)

		UIView.animate(
			withDuration: Constants.frameAnimationDuration,
			delay: 0.0,
			animations: {
				self.setFrame(.start)
			},
			completion: { _ in
				self.removeFromSuperview()
			}
		)
	}

	private func setConstraintsForContentView() {
		guard let contentViewSuperview = contentView.superview else {
			fatalError("contentView.superview is found nil.")
		}

		contentView.translatesAutoresizingMaskIntoConstraints = false
		var contentViewConstraints: [NSLayoutConstraint] = []
		contentViewConstraints.append(contentView.topAnchor.constraint(equalTo: contentViewSuperview.topAnchor))
		contentViewConstraints.append(contentView.leftAnchor.constraint(equalTo: contentViewSuperview.leftAnchor))
		contentViewConstraints.append(contentView.rightAnchor.constraint(equalTo: contentViewSuperview.rightAnchor))
		contentViewConstraints.append(contentView.heightAnchor.constraint(equalToConstant: notificationHeight))
		NSLayoutConstraint.activate(contentViewConstraints)
	}

	private func setFrame(_ status: NotificationFrameStatus) {
		guard let window = appWindow else { return }

		frame = CGRect(
			x: 0,
			y: statusBarHeight,
			width: window.screen.bounds.width,
			height: status == .start ? 0 : notificationHeight
		)
	}

	private func setSubviewsVisibilities(isHidden: Bool) {
		for view in contentView.subviews {
			view.isHidden = isHidden
		}
	}
}
