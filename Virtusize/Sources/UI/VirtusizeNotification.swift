//
//  VirtusizeNotification.swift
//
//  Copyright (c) 2021-present Virtusize KK
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

extension Notification.Name {
	static let productCheckData = Notification.Name(NotificationKey.productCheckData)
	static let storeProduct = Notification.Name(NotificationKey.storeProduct)
	static let sizeRecommendationData = Notification.Name(NotificationKey.sizeRecommendationData)
	static let inPageError = Notification.Name(NotificationKey.inPageError)
    static let setLanguage = Notification.Name(NotificationKey.setLanguage)
}

struct NotificationKey {
	static let productCheckData = "productCheckData"
	static let storeProduct = "storeProduct"
	static let sizeRecommendationData = "sizeRecommendationData"
	static let inPageError = "inPageError"
    static let setLanguage = "setLanguage"
}
