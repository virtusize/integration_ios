//
//  VirtusizeOrderItem.swift
//
//  Copyright (c) 2020 Virtusize AB
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

import Foundation

public struct VirtusizeOrderItem: Codable {
    // Id provided by the client, must be unique for a product
    private let productId: String
    // Name of the size e.g. `M`
    private let size: String
    // Alias of the size if not identical from the product page
    private let sizeAlias: String?
    // Eventual variant id if several products
    private let variantId: String?
    // The imageURL of the item. The image that will be shared with Virtusize
    private let imageUrl: String
    // The color of the item
    private let color: String?
    // An identifier for the gender
    private let gender: String?
    // Unit price is a Decimal type in the DB (12,2)
    private let unitPrice: Float
    // If not passed should be set to 1
    private let quantity: Int
    // Product page url if any
    private let url: String?
}
