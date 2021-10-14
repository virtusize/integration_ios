//
//  NotificationViewController.swift
//  Example
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
import VirtusizeUIKit

class NotificationViewController: UIViewController {
	private var infoNotification: VirtusizeUINotification!
	private var successNotification: VirtusizeUINotification!
	private var errorNotification: VirtusizeUINotification!

	private var notifications: [VirtusizeUINotification] = []
	private var index = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = DesignSystemComponent.notification.title

		let defaultButton = VirtusizeUIButton()
		defaultButton.setTitle("Show Notification", for: .normal)
		defaultButton.translatesAutoresizingMaskIntoConstraints = false
		defaultButton.addTarget(self, action: #selector(showNotification), for: .touchUpInside)
		view.addSubview(defaultButton)

		NSLayoutConstraint.activate([
			defaultButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			defaultButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])

		infoNotification = VirtusizeUINotification(
			title: "Some informational message for you.",
			style: .info
		)
		notifications.append(infoNotification)

		successNotification = VirtusizeUINotification(
			title: "Thank you for your patronage.",
			style: .success
		)
		notifications.append(successNotification)

		errorNotification = VirtusizeUINotification(
			title: "Oh no, something went wrong!",
			style: .error
		)
		notifications.append(errorNotification)
	}

	@objc func showNotification() {
		if index > notifications.count - 1 {
			index = 0
		}
		notifications[index].show()
		index += 1
	}
}
