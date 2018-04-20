//
//  VirtusizeButton.swift
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

public class VirtusizeButton: UIButton {

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	public func applyVirtusizeDesign() {
		self.tintColor = .black

		self.setTitle(NSLocalizedString("Check the fit", comment: "Check the fit button title"), for: .normal)

		self.backgroundColor = UIColor(white: 58.0 / 255.0, alpha: 1.0)
		self.tintColor = UIColor.white

		self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		let bundle = Bundle(for: type(of: self))
		if let image = UIImage(named: "vs-v-icon-black-small", in: bundle, compatibleWith: nil) {
			self.setImage(image, for: .normal)
		}
	}

	public var productId: String? {
		didSet {
			guard let externalId = productId else {
				isHidden = true
				return
			}

            Virtusize.sendEvent(name: "user-saw-product", data: nil, previousJSONResult: ["storeProductId": externalId])

			Virtusize.productCheck(externalId: externalId) { [weak self] (data, response, error) in
				self?.jsonResult = nil

				guard let data = data else {
					self?.isHidden = true
					return
				}

				do {
					let rootObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let root = rootObject as? JSONObject else {
                        self?.isHidden = true
						return
                    }

                    guard let dataObject = root["data"] as? JSONObject else {
                        self?.isHidden = true
						return
                    }

                    guard let isValid = dataObject["validProduct"] as? Bool, isValid == true else {
                        self?.isHidden = true
                        return
                    }

					if let sendImageToBackend = dataObject["fetchMetaData"] as? Bool,
						sendImageToBackend,
						let productImageURL = self?.productImageURL {
						Virtusize.sendProductImage(url: productImageURL, for: externalId, jsonResult: dataObject)
					}

					// keep values of JSON response
					self?.jsonResult = root
					self?.isHidden = false

					Virtusize.sendEvent(name: "user-saw-widget-button", data: nil, previousJSONResult: root)
				}
				catch {
					self?.isHidden = true
				}
			}
		}
	}

	public var productImageURL: URL? {
		didSet {

		}
	}

	internal var jsonResult: JSONObject?

}
