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
	// Set up the @state property to control opening the Virtusize web view
	@State var showVirtusizeWebView = false

    var body: some View {
		VStack {
			SwiftUIVirtusizeButton(
				action: {
					// Set showVirtusizeWebView to true when the button is clicked
					showVirtusizeWebView = true
				},
				// Optional: You can customize the button by accessing it here
				label: { virtusizeButton in
//					virtusizeButton.setTitle("Virtusize", for: .normal)
//					virtusizeButton.backgroundColor = .vsTealColor
				},
				// Set up the product's external ID and image URL here
				storeProduct: VirtusizeProduct(
					externalId: "vs_dress",
					imageURL: URL(string: "http://www.example.com/image.jpg")
				),
				// Optional: You can use our default styles either Black or Teal for the button
				// If you want to customize the button on your own, please do not set up the default style
				defaultStyle: .BLACK
			)
			.sheet(isPresented: $showVirtusizeWebView) {
				SwiftUIVirtusizeViewController(
					// Optional: Set up WKProcessPool to allow cookie sharing.
					processPool: WKProcessPool(),
					// Optional: You can use this callback closure to receive Virtusize events
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
					// Optional: You can use this callback closure to receive Virtusize SDK errors
					didReceiveError: { error in
						print(error)
					}
				)
			}

			// You can make the Virtusize web view full screen by using fullScreenCover (only available for iOS version 14.0+
//				.fullScreenCover(isPresented: $showVirtusizeWebView, content: {
//					SwiftUIVirtusizeViewController()
//				})
			// You can set the transition from moving bottom to up when the Virtusize web view is opening
//				.transition(.move(edge: .top))

			// Optional: You can set up NotificationCenter listeners for debugging the initial product data check
			// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
			// with the cause of the failure
			// - `Virtusize.productDataCheckDidSucceed`
			.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidSucceed)) { notification in
				print(notification)
			}
			.onReceive(NotificationCenter.default.publisher(for: Virtusize.productDataCheckDidFail)) { notification in
				print(notification)
			}

			// MARK: The Order API
			// This button is to show how to send the order using `Virtusize.sendOrder` function
			Button("Send an Order", action: {
				sendOrderSample()
			})
			.font(.system(size: 12))
			.padding(.horizontal, 12)
			.padding(.vertical, 10)
			.background(Color.vsTealColor)
			.foregroundColor(.white)
			.cornerRadius(20)
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
			productId: "A00001",
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
