//
//  VirtusizeOrderItem.swift
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

/// This structure wraps the parameters of the order item for the API request of sending the order
public struct VirtusizeOrderItem: Codable {
    /// The external provide ID provided by the client. It must be unique for a product.
    private let externalProductId: String
    /// The name of the size, e.g. "S", "M", etc.
    private let size: String
    /// The alias of the size is added if the size name is not identical from the product page
    private let sizeAlias: String?
    /// The variant ID that is set on the product SKU, color, or size if there are several options
    private let variantId: String?
    /// The image URL of the item
    private let imageUrl: String
    /// The color of the item, e.g. "Red", etc.
    private let color: String?
    /// An identifier for the gender, e.g. "W", "Women", etc.
    private let gender: String?
    /// The product price that is a floating number with a maximum of 12 digits and 2 decimals (12, 2)
    private let unitPrice: Float
    /// The currency code, e.g. "JPY", etc.
    private let currency: String
    /// The number of the item purchased. If it's not passed, It will be set to 1
    private let quantity: Int
    /// The URL of the product page. Please make sure this is a URL that users can access.
    private let url: String?

    /// Initializes the VirtusizeOrderItem structure
    public init(externalProductId: String, size: String, sizeAlias: String? = nil, variantId: String? = nil,
                imageUrl: String, color: String? = nil, gender: String? = nil, unitPrice: Float,
                currency: String, quantity: Int = 1, url: String) {
        self.externalProductId = externalProductId
        self.size = size
        self.sizeAlias = sizeAlias
        self.variantId = variantId
        self.imageUrl = imageUrl
        self.color = color
        self.gender = gender
        self.unitPrice = unitPrice
        self.currency = currency
        self.quantity = quantity
        self.url = url
    }
}
