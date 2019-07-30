//
//  ViewController.swift
//
//  Copyright (c) 2018 Virtusize AB
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
import Virtusize

class ViewController: UIViewController {

	@IBOutlet weak var checkTheFitButton: VirtusizeButton!

	override func viewDidLoad() {
		super.viewDidLoad()
        // NotificationCenter listener for debugging the initial product data check
        // - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
        // with the cause of the failure
        // - `Virtusize.productDataCheckDidSucceed`
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(productDataCheckDidFail(_:)),
                                               name: Virtusize.productDataCheckDidFail,
                                               object: Virtusize.self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(productDataCheckDidSucceed(_:)),
                                               name: Virtusize.productDataCheckDidSucceed,
                                               object: Virtusize.self)

        checkTheFitButton.storeProduct = VirtusizeProduct(
            externalId: "vs_dress",
            imageURL: URL(string: "http://www.example.com/image.jpg"))
		checkTheFitButton.applyDefaultStyle()
	}

	@IBAction func checkTheFit() {
        if let virtusize = VirtusizeViewController(
            product: checkTheFitButton.storeProduct,
            handler: self) {
            // POTENTIAL ANALYTICS CODE
            present(virtusize, animated: true, completion: nil)
        }
	}
    // You should use those to debug during development
    @objc func productDataCheckDidFail(_ notification: Notification) {
        print(notification)
    }
    @objc func productDataCheckDidSucceed(_ notification: Notification) {
        print(notification)
    }
}

extension ViewController: VirtusizeMessageHandler {
    func virtusizeControllerShouldClose(_ controller: VirtusizeViewController) {
        dismiss(animated: true, completion: nil)
    }

    func virtusizeController(_ controller: VirtusizeViewController, didReceiveEvent event: VirtusizeEvent) {
        print(event)
		switch event.name {
		case "user-opened-widget":
            return
		case "user-opened-panel-compare":
            return
		default:
            return
		}
	}

    func virtusizeController(_ controller: VirtusizeViewController, didReceiveError error: VirtusizeError) {
        print(error)
        dismiss(animated: true, completion: nil)
    }
}
