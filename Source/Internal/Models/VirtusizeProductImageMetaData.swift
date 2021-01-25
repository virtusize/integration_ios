//
//  VirtusizeProductImageMetaData.swift
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

/// This structure wraps the parameters of product image meta data for the API request `sendProductImage`
internal struct VirtusizeProductMetaData: Codable {
    /// An integer that represents the store id from the product data
    private let storeId: Int?
    /// A string to represent the id that will be used to reference this product in Virtusize API
    private let externalId: String
    /// The URL string of the product image that is fully qualified with the domain and the protocol
    private let imageUrl: String
    /// The API key that is unique and provided for Virtusize clients
    private let apiKey: String

    /// Initializes the VirtusizeProductMetaData structure
    public init(storeId: Int?, externalId: String, imageUrl: String, apiKey: String) {
        self.storeId = storeId
        self.externalId = externalId
        self.imageUrl = imageUrl
        self.apiKey = apiKey
    }
}
