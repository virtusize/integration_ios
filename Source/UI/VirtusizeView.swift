//
//  VirtusizeView.swift
//
//  Copyright (c) 2020 Virtusize KK
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

import WebKit

/// A protocol for the Virtusize specific views such as `VirtusizeButton` and `VirtusizeInPageView`
public protocol VirtusizeView {
    var presentingViewController: UIViewController? { get set }
    var messageHandler: VirtusizeMessageHandler? { get set }
	var style: VirtusizeViewStyle { get }
	var memoryAddress: String { get }
	var isDeallocated: Bool? { get set }

	/// Sets up the loading UI
    func isLoading()
}

/// Extension functions for `VirtusizeView`
extension VirtusizeView {

    /// Opens the Virtusize web view
	internal func openVirtusizeWebView(eventHandler: VirtusizeEventHandler? = nil) {
		if let virtusize = VirtusizeWebViewController(
			messageHandler: messageHandler,
			eventHandler: eventHandler,
			processPool: Virtusize.processPool
		) {
            presentingViewController?.present(virtusize, animated: true, completion: nil)
        }
    }

	/// Handle the situation where the view controller will be added or removed from a container view controller.
	internal func handleWillMoveWindow(_ toWindow: UIWindow?, shouldBeDeallocated: (Bool) -> Void) {
		// will dismiss a view controller, which is not a VirtusizeWebViewController
		if toWindow == nil {
			if !virtusizeWebViewControllerWillBeOnTopOfScreen() {
				shouldBeDeallocated(true)
				Virtusize.activeVirtusizeViews = Virtusize.virtusizeViews
					.filter {
						$0.isDeallocated != true
					}
			}
		// will move to an existing view controller
		} else {
			shouldBeDeallocated(false)
		}

		VirtusizeRepository.shared.updateCurrentProductBy(
			vsViewMemoryAddress: Virtusize.activeVirtusizeViews.last?.memoryAddress
		)
	}

	private func virtusizeWebViewControllerWillBeOnTopOfScreen() -> Bool {
		return getTopViewController(base: self.presentingViewController) is VirtusizeWebViewController
	}

	private func getTopViewController(base: UIViewController?) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return getTopViewController(base: nav.visibleViewController)
		} else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
			return getTopViewController(base: selected)

		} else if let presented = base?.presentedViewController {
			return getTopViewController(base: presented)
		}
		return base
	}
}
