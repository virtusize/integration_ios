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
		static let padding = CGFloat(10)
		static let leftImageViewSize = CGFloat(24)
		static let closeImageViewSize = CGFloat(16)
	}

	private lazy var appWindow: UIWindow? = {
		return UIApplication.safeShared?.windows.first { $0.isKeyWindow }
	}()

	private var titleLabelHeight: CGFloat {
		return titleLabel.intrinsicContentSize.height + Constants.padding * 2
	}

	public init (
		title: String,
		style: VirtusizeUINotificationStyle = .info
	) {
		super.init(frame: .zero)
		backgroundColor = .vsGray900Color

		contentView = UIView()
		addSubview(contentView)

		setNotificationImageView(style: style)
		setCloseImageView()
		setTitle(title)
	}

	@available(*, unavailable)
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented. Use init(title:, style:) instead.")
	}

	private func setNotificationImageView(style: VirtusizeUINotificationStyle) {
		notificationImageView = UIImageView(image: VirtusizeAssets.logo)

		contentView.addSubview(notificationImageView)

		notificationImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			notificationImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			notificationImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
			notificationImageView.widthAnchor.constraint(equalToConstant: Constants.leftImageViewSize),
			notificationImageView.heightAnchor.constraint(equalToConstant: Constants.leftImageViewSize)
		])
	}

	private func setCloseImageView() {
		closeImageView = UIImageView(image: VirtusizeAssets.closeWhite)
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

		titleLabel.textColor = .white

		contentView.addSubview(titleLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			titleLabel.leadingAnchor.constraint(equalTo: notificationImageView.trailingAnchor, constant: 10),
			titleLabel.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -10)
		])
	}

	public func show(position: VirtusizeUINotificationPosition = .top) {
		guard !isDisplaying else { return }

		self.setConstraintsForContentView(position: position)
		self.updateFrame(position: position)

		self.appWindow?.addSubview(self)

		self.isDisplaying = true

		alpha = 0
		UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
			self.alpha = 1
		}){ completed in
			if completed && self.autoClose {
				UIView.animate(withDuration: 0, delay: self.autoCloseDelay, options: .curveEaseInOut, animations: {
					self.alpha = 0
				}){ completed in
					self.dismiss()
				}
			}
		}
	}

	public func dismiss() {
		guard isDisplaying else { return }

		isDisplaying = false
		self.removeFromSuperview()
	}

	private func setConstraintsForContentView(position: VirtusizeUINotificationPosition) {
		guard let contentViewSuperview = contentView.superview else {
			fatalError("contentView.superview is found nil.")
		}

		contentView.translatesAutoresizingMaskIntoConstraints = false
		var contentViewConstraints: [NSLayoutConstraint] = []
		if position == .top {
			contentViewConstraints.append(contentView.topAnchor.constraint(equalTo: contentViewSuperview.topAnchor))
		} else if position == .bottom {
			contentViewConstraints.append(contentView.bottomAnchor.constraint(equalTo: contentViewSuperview.bottomAnchor))
		}
		contentViewConstraints.append(contentView.leftAnchor.constraint(equalTo: contentViewSuperview.leftAnchor))
		contentViewConstraints.append(contentView.rightAnchor.constraint(equalTo: contentViewSuperview.rightAnchor))
		contentViewConstraints.append(contentView.heightAnchor.constraint(equalToConstant: titleLabelHeight))
		NSLayoutConstraint.activate(contentViewConstraints)
	}

	private func updateFrame(position: VirtusizeUINotificationPosition) {
		guard let window = appWindow else { return }
		frame = CGRect(
			x: position == .top ? 0 : 0,
			y: position == .top ?
				(UIApplication.safeShared?.statusBarFrame.height ?? 0) : window.screen.bounds.height - titleLabelHeight,
			width: window.screen.bounds.width,
			height: titleLabelHeight
		)
	}
}
