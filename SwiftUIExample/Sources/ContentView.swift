//
//  ContentView.swift
//  SwiftUIExample
//
//  Copyright (c) 2021-present Virtusize KK
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

import SwiftUI
import Virtusize
import WebKit

struct ContentView: View {
	// Declare a Bool state to control when to open the Virtusize web view
	@State var showVirtusizeWebView = false

	// Optional: Declare a Boolean state to update the view based on the result of product data check
	@State var productDataCheckCompleted = false

	private var product: VirtusizeProduct

	init() {
		// Set up the product information in order to populate the Virtusize view
		product = VirtusizeProduct(
			externalId: "vs_dress",
			imageURL: URL(string: "http://www.example.com/image.jpg")
		)

		Virtusize.load(product: product)

		// MARK: The Order API
		sendOrderSample()
	}

    var body: some View {
		VStack {
			Spacer()
			// MARK: SwiftUIVirtusizeButton
			SwiftUIVirtusizeButton(
				product: product,
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional) You can customize the button by accessing it here
				uiView: { virtusizeButton in
						virtusizeButton.setTitle("サイズチェック", for: .normal)
						virtusizeButton.backgroundColor = .vsGray900Color
				},
				// (Optional) You can use our default styles: either Black or Teal for the button
				// If you want to customize the button on your own, please omit defaultStyle
				defaultStyle: .BLACK
			)
			.padding(.bottom, 16)

			// MARK: SwiftUIVirtusizeInPageStandard
			SwiftUIVirtusizeInPageStandard(
				product: product,
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional): You can customize the button by accessing it here
				uiView: { virtusizeInPageStandard in
					virtusizeInPageStandard.buttonFontSize = 12
					virtusizeInPageStandard.messageFontSize = 12
					virtusizeInPageStandard.inPageStandardButtonBackgroundColor = .vsGray900Color
					virtusizeInPageStandard.setHorizontalMargin(margin: 16)
				},
				// (Optional): You can use our default styles: either Black or Teal for the InPage Standard view.
				// The default is set to .BLACK.
				defaultStyle: .BLACK
			)
			.padding(.bottom, 16)

			// MARK: SwiftUIVirtusizeInPageMini
			SwiftUIVirtusizeInPageMini(
				product: product,
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// (Optional): You can customize the button by accessing it here
				uiView: { virtusizeInPageMini in
					virtusizeInPageMini.messageFontSize = 12
					virtusizeInPageMini.buttonFontSize = 10
					virtusizeInPageMini.inPageMiniBackgroundColor = .vsTealColor
					virtusizeInPageMini.setHorizontalMargin(margin: 16)
				},
				// (Optional): You can use our default styles: either Black or Teal for the InPage Mini view.
				// The default is set to .BLACK.
				defaultStyle: .TEAL
			)

			Spacer()
		}
		// (Optional): Hide the space of the view when the product data check is not completed or not valid
		.frame(height: productDataCheckCompleted ? nil : 0)
		// MARK: SwiftUIVirtusizeViewController
		.sheet(isPresented: $showVirtusizeWebView) {
			SwiftUIVirtusizeViewController(
				product: product,
				// (Optional): Set up WKProcessPool to allow cookie sharing
				processPool: WKProcessPool(),
				// (Optional): You can use this callback closure to receive Virtusize events
				didReceiveEvent: { event in
					print(event)
					switch event.name {
					case "user-opened-widget":
						return
					case "user-opened-panel-compare":
						return
					default:
						return
					}
				},
				// (Optional): You can use this callback closure to receive Virtusize SDK errors
				didReceiveError: { error in
					print(error)
				}
			)
		}
		// You can make the Virtusize web view full screen by using fullScreenCover (only available for iOS version 14.0+)
//			.fullScreenCover(isPresented: $showVirtusizeWebView, content: {
//				SwiftUIVirtusizeViewController()
//			})
		// (Optional): You can set up NotificationCenter listeners  to debug the product data check
		// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
		// with the cause of the failure
		// - `Virtusize.productDataCheckDidSucceed`
		.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidSucceed)) { notification in
			print(notification)

			productDataCheckCompleted = true
		}
		.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidFail)) { notification in
			print(notification)
		}
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
