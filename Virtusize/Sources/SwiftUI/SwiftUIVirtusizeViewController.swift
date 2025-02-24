//
//  SwiftUIVirtusizeViewController.swift
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

#if canImport(SwiftUI)
import SwiftUI
import WebKit

#if (arch(arm64) || arch(x86_64))
public struct SwiftUIVirtusizeViewController: UIViewControllerRepresentable {
	public typealias UIViewControllerType = VirtusizeWebViewController

	private var clientProduct: VirtusizeProduct
	private var processPool: WKProcessPool?
	private var event: ((VirtusizeEvent) -> Void)?
	private var error: ((VirtusizeError) -> Void)?

	public init(
		product: VirtusizeProduct,
		processPool: WKProcessPool? = nil,
		didReceiveEvent event: ((VirtusizeEvent) -> Void)? = nil,
		didReceiveError error: ((VirtusizeError) -> Void)? = nil
	) {
		self.clientProduct = product
		self.processPool = processPool
		self.event = event
		self.error = error
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(didReceiveEvent: event, didReceiveError: error)
	}

	public func makeUIViewController(context: Context) -> VirtusizeWebViewController {
		let repository = VirtusizeRepository.shared

		// update last product

		// fetch client product

		repository.lastProductOnVirtusizeWebView = repository.serverStoreProductSet
			.filter({ product in
				product.externalId == clientProduct.externalId
			})
			.first
		guard let virtusizeViewController = VirtusizeWebViewController(
			product: clientProduct,
			messageHandler: context.coordinator,
//			eventHandler: Virtusize.virtusizeEventHandler,
			processPool: processPool
		) else {
			fatalError("Cannot load VirtusizeViewController")
		}
		virtusizeViewController.modalPresentationStyle = .fullScreen
		return virtusizeViewController
	}

	public func updateUIViewController(_ uiViewController: VirtusizeWebViewController, context: Context) {
//		if uiViewController.isViewWillAppeared {
//			uiViewController.isViewWillAppeared = false
//			if uiViewController.isVirtusizeClosed {
//				uiViewController.isVirtusizeClosed = false
//				uiViewController.loadWebView()
//			}
//		}
	}
}

extension SwiftUIVirtusizeViewController {
	public class Coordinator: VirtusizeMessageHandler {

		private var eventListener: ((VirtusizeEvent) -> Void)?
		private var errorListener: ((VirtusizeError) -> Void)?

		init(
			didReceiveEvent event: ((VirtusizeEvent) -> Void)?,
			didReceiveError error: ((VirtusizeError) -> Void)?
		) {
			self.eventListener = event
			self.errorListener = error
		}

		public func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveError error: VirtusizeError) {
			self.errorListener?(error)
		}

		public func virtusizeController(_ controller: VirtusizeWebViewController?, didReceiveEvent event: VirtusizeEvent) {
			self.eventListener?(event)
		}
	}
}
#endif
#endif
