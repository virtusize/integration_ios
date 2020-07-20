//
//  VirtusizeProduct.swift
//
//  Copyright (c) 2018 Virtusize KK
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

/// This structure represents a product in Virtusize API
public struct VirtusizeProduct {
    /// A string to represent the ID that will be used to reference this product in Virtusize API
    public let externalId: String

    /// The URL of the product image that is fully qualified with the domain and the protocol
    public let imageURL: URL?

    /// The product data from the response of the `productDataCheck` request
    internal var context: JSONObject?

    /// Initializes the VirtusizeProduct structure
    internal init(externalId: String, imageURL: URL? = nil, context: JSONObject? = nil) {
        self.externalId = externalId
        self.imageURL = imageURL
        self.context = context
    }
}

extension VirtusizeProduct {
    public init(externalId: String, imageURL: URL? = nil) {
        self.init(externalId: externalId, imageURL: imageURL, context: nil)
    }
}
