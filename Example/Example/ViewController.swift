//
//  ViewController.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

class ViewController: UIViewController {

    @IBOutlet weak var checkTheFitButton: VirtusizeButton!
    @IBOutlet weak var inPageMini: VirtusizeInPageMini!

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

        // Set up the product information in order to populate the Virtusize view
        Virtusize.product = VirtusizeProduct(
            externalId: "vs_dress",
            imageURL: URL(string: "http://www.example.com/image.jpg")
        )

        // Optional: Set up WKProcessPool to allow cookie sharing.
        Virtusize.processPool = WKProcessPool()

        // MARK: VirtusizeButton
        // 1. Set up checkTheFitButton that is added in Interface Builder
        Virtusize.setVirtusizeView(self, checkTheFitButton)
        checkTheFitButton.style = .TEAL

        // 2. Add the VirtusizeButton programmatically
        let checkTheFitButton2 = VirtusizeButton()
        view.addSubview(checkTheFitButton2)
        Virtusize.setVirtusizeView(self, checkTheFitButton2)
        checkTheFitButton2.style = .BLACK
        // Set up constraints if needed
        checkTheFitButton2.translatesAutoresizingMaskIntoConstraints = false
        checkTheFitButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        checkTheFitButton2.bottomAnchor.constraint(equalTo: checkTheFitButton.topAnchor, constant: -16).isActive = true

        // MARK: VirtusizeInPageMini
        // 1. Set up inPageMini that is added in Interface Builder
        Virtusize.setVirtusizeView(self, inPageMini)
        inPageMini.style = .BLACK

        // 2. If you add the InPageMini view programmatically
        let inPageMini2 = VirtusizeInPageMini()
        view.addSubview(inPageMini2)
        // Set up constraints if needed
        inPageMini2.translatesAutoresizingMaskIntoConstraints = false
        inPageMini2.topAnchor.constraint(equalTo: inPageMini.bottomAnchor, constant: 16).isActive = true
        Virtusize.setVirtusizeView(self, inPageMini2)
        inPageMini2.inPageMiniBackgroundColor = #colorLiteral(red: 0.262745098, green: 0.5960784314, blue: 0.9882352941, alpha: 1)
        // You can set up horizontal margins by using `setupHorizontalMargin`
        inPageMini2.setupHorizontalMargin(view: view, margin: 16)

        // MARK: VirtusizeInPageStandard
        let inPageStandard = VirtusizeInPageStandard()
        view.addSubview(inPageStandard)
        inPageStandard.translatesAutoresizingMaskIntoConstraints = false
        inPageStandard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inPageStandard.topAnchor.constraint(equalTo: inPageMini2.bottomAnchor, constant: 16).isActive = true
        Virtusize.setVirtusizeView(self, inPageStandard)
        inPageStandard.setupHorizontalMargin(view: view, margin: 16)

        // MARK: The Order API
        sendOrderSample()
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
