//
//  ViewController.swift
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

import UIKit
import WebKit
import Virtusize
import VirtusizeUIKit

class ViewController: UIViewController {

	@IBOutlet weak var checkTheFitButton: VirtusizeButton!
	@IBOutlet weak var inPageMini: VirtusizeInPageMini!

	// swiftlint:disable function_body_length
	override func viewDidLoad() {
		super.viewDidLoad()

		setNavigationBarStyle()

		// NotificationCenter listener for debugging the initial product data check
		// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
		// with the cause of the failure
		// - `Virtusize.productDataCheckDidSucceed`
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(productDataCheckDidFail(_:)),
			name: Virtusize.productDataCheckDidFail,
			object: Virtusize.self
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(productDataCheckDidSucceed(_:)),
			name: Virtusize.productDataCheckDidSucceed,
			object: Virtusize.self
		)

		/// Set up the product information
		let product1 = VirtusizeProduct(
			externalId: "vs_dress",
			imageURL: URL(string: "http://www.example.com/image.jpg")
		)
		/// Loads the product in order to populate the Virtusize views associated with `product1`
		Virtusize.load(product: product1)

		/// Set up the product information
		let product2 = VirtusizeProduct(
			externalId: "vs_pants",
			imageURL: URL(string: "http://www.example.com/image.jpg")
		)
		/// Loads the product in order to populate the Virtusize views associated with `product2`
		Virtusize.load(product: product2)

		// Optional: Set up WKProcessPool to allow cookie sharing.
		Virtusize.processPool = WKProcessPool()

		// MARK: VirtusizeButton
		// 1. Set up checkTheFitButton that is added in Interface Builder
		Virtusize.setVirtusizeView(self, checkTheFitButton, product: product1)
		// You can set up the Virtusize button style
		checkTheFitButton.style = .TEAL

		/// you can use `VirtusizeAssets` to access Virtusize SDK assets, including images and colors
		// checkTheFitButton.setImage(VirtusizeAssets.icon, for: .normal)

		// 2. Add the VirtusizeButton programmatically
		let checkTheFitButton2 = VirtusizeButton()
		view.addSubview(checkTheFitButton2)
		Virtusize.setVirtusizeView(self, checkTheFitButton2, product: product2)
		checkTheFitButton2.style = .BLACK
		// Set up constraints if needed
		checkTheFitButton2.translatesAutoresizingMaskIntoConstraints = false
		checkTheFitButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		checkTheFitButton2.bottomAnchor.constraint(equalTo: checkTheFitButton.topAnchor, constant: -16).isActive = true

		// MARK: VirtusizeInPageMini
		// 1. Set up inPageMini that is added in Interface Builder
		Virtusize.setVirtusizeView(self, inPageMini, product: product1)
		// You can set the Virtusize InPage Mini style
		inPageMini.style = .BLACK

		// 2. If you add the InPageMini view programmatically
		let inPageMini2 = VirtusizeInPageMini()
		view.addSubview(inPageMini2)
		Virtusize.setVirtusizeView(self, inPageMini2, product: product2)
		inPageMini2.inPageMiniBackgroundColor = #colorLiteral(red: 0.262745098, green: 0.5960784314, blue: 0.9882352941, alpha: 1)
		// You can set the horizontal margins by using `setHorizontalMargin`
		inPageMini2.setHorizontalMargin(view: view, margin: 16)
		// You can set the font sizes for the InPage Mini texts
		inPageMini2.messageFontSize = 12
		inPageMini2.buttonFontSize = 10
		// Set up constraints if needed
		inPageMini2.translatesAutoresizingMaskIntoConstraints = false
		inPageMini2.topAnchor.constraint(equalTo: inPageMini.bottomAnchor, constant: 16).isActive = true

		// MARK: VirtusizeInPageStandard
		// If you add the InPageMini view programmatically
		let inPageStandard = VirtusizeInPageStandard()
		view.addSubview(inPageStandard)
		Virtusize.setVirtusizeView(self, inPageStandard, product: product1)
		// You can set the horizontal margins by using `setHorizontalMargin`
		inPageStandard.setHorizontalMargin(view: view, margin: 16)
		// You can set the Virtusize InPage Standard style
		inPageStandard.style = .BLACK
		// You can set the background color of the size check button
		inPageStandard.inPageStandardButtonBackgroundColor = .vsGray900Color
		// You can set the font sizes for the InPage texts
		inPageStandard.buttonFontSize = 12
		inPageStandard.messageFontSize = 12
		// Set up constraints if needed
		inPageStandard.translatesAutoresizingMaskIntoConstraints = false
		inPageStandard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inPageStandard.topAnchor.constraint(equalTo: inPageMini2.bottomAnchor, constant: 16).isActive = true

		let dsButton = VirtusizeUIButton()
		view.addSubview(dsButton)
		dsButton.setTitle("Design System", for: .normal)
		dsButton.translatesAutoresizingMaskIntoConstraints = false
		dsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		dsButton.topAnchor.constraint(equalTo: inPageStandard.bottomAnchor, constant: 32).isActive = true
		dsButton.addTarget(self, action: #selector(clickDesignSystemButton), for: .touchUpInside)

		// MARK: The Order API
//		sendOrderSample()
	}

	@objc private func clickDesignSystemButton() {
		let viewController = DesignSystemViewController()
		navigationController?.pushViewController(viewController, animated: true)
	}

	/// Demonstrates how to send an order to the Virtusize server
	///
	/// - Note:
	/// The properties `sizeAlias`, `variantId`, `color`, `gender` and `url`
	/// for `VirtusizeOrderItem` are optional
	///
	/// If `quantity` is not provided, it will be set to 1 automatically
	///
	private func sendOrderSample() {
		var virtusizeOrder = VirtusizeOrder(externalOrderId: "4000111032")
		let item = VirtusizeOrderItem(
			externalProductId: "A00001",
			size: "L",
			sizeAlias: "Large",
			variantId: "A00001_SIZEL_RED",
			imageUrl: "http://images.example.com/products/A00001/red/image1xl.jpg",
			color: "Red",
			gender: "W",
			unitPrice: 5100.00,
			currency: "JPY",
			quantity: 1,
			url: "http://example.com/products/A00001"
		)
		virtusizeOrder.items = [item]

		Virtusize.sendOrder(
			virtusizeOrder,
			// This success callback is optional and gets called when the app successfully sends the order
			onSuccess: {
				print("Successfully sent the order")
			},
			// This error callback is optional and gets called when an error occurs
			// when the app is sending the order
			onError: { error in
				print("Failed to send the order, error: \(error.debugDescription)")
			})
	}

	// You should use those to debug during development
	@objc func productDataCheckDidFail(_ notification: Notification) {
		print(notification)
	}
	@objc func productDataCheckDidSucceed(_ notification: Notification) {
		print(notification)
	}

	private func setNavigationBarStyle() {
		navigationItem.title = "Virtusize Example App"
		navigationController?.navigationBar.tintColor = UIColor.white
		let textAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.white
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.barStyle = UIBarStyle.blackTranslucent
		navigationController?.navigationBar.barTintColor = UIColor.vsTealColor
		setNavigationBarCustomHeight()
	}

	private func setNavigationBarCustomHeight() {
		navigationController?.navigationBar.frame = CGRect(
			x: 0,
			y: UIApplication.shared.statusBarFrame.height,
			width: view.window?.bounds.width ?? 0,
			height: 48
		)
	}
}

extension ViewController: VirtusizeMessageHandler {
	func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveEvent event: VirtusizeEvent) {
		print(event)
		// swiftlint:disable switch_case_alignment
		switch event.name {
			case "user-opened-widget":
				return
			case "user-opened-panel-compare":
				return
			default:
				return
		}
	}

	func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveError error: VirtusizeError) {
		print(error)
	}
}
