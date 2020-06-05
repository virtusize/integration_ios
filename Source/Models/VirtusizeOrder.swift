//
//  VirtusizeOrder.swift
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

/// This structure wraps the parameters for the API request of sending the order
public struct VirtusizeOrder: Codable {
    /// The order ID provided by the client
    private let externalOrderId: String
    /// The unique user ID from the client system.
    /// `Virtusize.userId` should be set for sending the order
    internal var externalUserId: String?
    /// A country code is set for each region i.e. ISO-3166.
    /// This is set by the response of the request that retrieves the specific store info
    internal var region: String?
    /// An array of the order items.
    public var items: [VirtusizeOrderItem]
}

extension VirtusizeOrder {
    public init(externalOrderId: String) {
        self.init(externalOrderId: externalOrderId, externalUserId: nil, region: nil, items: [])
    }

    public init(externalOrderId: String, items: [VirtusizeOrderItem]) {
        self.init(externalOrderId: externalOrderId, externalUserId: nil, region: nil, items: items)
    }
}
