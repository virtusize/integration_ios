//
//  UIApplication+Extensions.swift
//  VirtusizeCore
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

#if !os(watchOS)
public extension UIApplication {

	/// A safe accessor for `UIApplication.shared`
	///
	/// - Note: `UIApplication.shared` is not supported under app extension. It needs to be accessed in a safe way.
	static var safeShared: UIApplication? {
		let sharedSelector = NSSelectorFromString("sharedApplication")
		guard UIApplication.responds(to: sharedSelector) else {
			return nil
		}
		return UIApplication.perform(sharedSelector)?.takeUnretainedValue() as? UIApplication
	}

	/// A safe accessor to call the function that opens a URL
	func safeOpenURL(_ url: URL) {
		guard self.canOpenURL(url) else { return }
		guard self.perform(NSSelectorFromString("openURL:"), with: url) != nil else {
			return
		}
	}

    /// Gets the top most view controller
	///
	/// - Parameter baseVC: the base view controller
	func getTopMostViewController() -> UIViewController? {
       let baseVC : UIViewController? = UIApplication.safeShared?.windows.filter {$0.isKeyWindow}.first?.rootViewController
		if let navVC = baseVC as? UINavigationController {
			return navVC.visibleViewController
		} else if let tabController = baseVC as? UITabBarController, let selectedTabVC = tabController.selectedViewController {
			return selectedTabVC
		} else if let presentedVC = baseVC?.presentedViewController {
			return presentedVC
		}
		return baseVC
	}
}
extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.safeShared?.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.safeShared?.keyWindow
        }
    }
}
#endif
