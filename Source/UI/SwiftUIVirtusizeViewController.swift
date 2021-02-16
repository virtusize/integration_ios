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

import SwiftUI
import WebKit

@available(iOSApplicationExtension 13.0, *)
public struct SwiftUIVirtusizeViewController: UIViewControllerRepresentable {
	public typealias UIViewControllerType = VirtusizeViewController

	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

	private var processPool: WKProcessPool?
	private var event: ((VirtusizeEvent) -> Void)?
	private var error: ((VirtusizeError) -> Void)?

	public init(
		processPool: WKProcessPool? = nil,
		didReceiveEvent event: ((VirtusizeEvent) -> Void)? = nil,
		didReceiveError error: ((VirtusizeError) -> Void)? = nil
		) {
		self.processPool = processPool
		self.event = event
		self.error = error
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self, didReceiveEvent: event, didReceiveError: error)
	}

	public func makeUIViewController(context: Context) -> VirtusizeViewController {
		guard let virtusizeViewController = VirtusizeViewController(
			handler: context.coordinator,
			processPool: processPool
		) else {
			fatalError("Cannot load VirtusizeViewController")
		}
		virtusizeViewController.modalPresentationStyle = .fullScreen
		return virtusizeViewController
	}

	public func updateUIViewController(_ uiViewController: VirtusizeViewController, context: Context) {}

	private func dismiss() {
		presentationMode.wrappedValue.dismiss()
	}

}

@available(iOSApplicationExtension 13.0, *)
extension SwiftUIVirtusizeViewController {

	public class Coordinator: VirtusizeMessageHandler {

		private var parent: SwiftUIVirtusizeViewController
		private var eventListener: ((VirtusizeEvent) -> Void)?
		private var errorListener: ((VirtusizeError) -> Void)?

		init(
			_ parent: SwiftUIVirtusizeViewController,
			didReceiveEvent event: ((VirtusizeEvent) -> Void)?,
			didReceiveError error: ((VirtusizeError) -> Void)?
		) {
			self.parent = parent
			self.eventListener = event
			self.errorListener = error
		}

		public func virtusizeController(_ controller: VirtusizeViewController, didReceiveError error: VirtusizeError) {
			self.errorListener?(error)
		}

		public func virtusizeController(_ controller: VirtusizeViewController, didReceiveEvent event: VirtusizeEvent) {
			self.eventListener?(event)
		}

		public func virtusizeControllerShouldClose(_ controller: VirtusizeViewController) {
			parent.dismiss()
		}
	}
}
