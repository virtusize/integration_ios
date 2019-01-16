//
//  Deserializer.swift
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

import Foundation

internal struct Deserializer {
    static func product(from product: VirtusizeProduct, withData data: Data?) -> VirtusizeProduct? {
        guard let data = data,
            let rootObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = rootObject as? JSONObject,
            let dataObject = root["data"] as? JSONObject else {
            return nil
        }

        Virtusize.sendEvent(VirtusizeEvent(name: "user-saw-product"), withContext: root)

        guard let isValid = dataObject["validProduct"] as? Bool, isValid else {
            return nil
        }

        if let sendImageToBackend = dataObject["fetchMetaData"] as? Bool,
            sendImageToBackend,
            product.imageURL != nil,
            let storeId = dataObject["storeId"] as? Int {
            Virtusize.sendProductImage(of: product, forStore: storeId)
        }

        Virtusize.sendEvent(VirtusizeEvent(name: "user-saw-widget-button"), withContext: root)

        // keep values of JSON response
        return VirtusizeProduct(
            externalId: product.externalId,
            imageURL: product.imageURL,
            context: root)
    }

    static func event(data: Any?) throws -> VirtusizeEvent {
        let event: [String: Any]

        if let eventData = data as? [String: Any] {
            event = eventData
        } else if let data = data as? Data,
            let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
            let eventData = deserialized as? [String: Any] {
            event = eventData
        } else if let string = data as? String {
            guard let data = string.data(using: .utf8) else {
                throw VirtusizeError.encodingError
            }
            if let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
                let eventData = deserialized as? [String: Any] {
                event = eventData
            } else {
                throw VirtusizeError.deserializationError
            }
        } else {
            throw VirtusizeError.deserializationError
        }

        guard let eventName: String = event["name"] as? String else {
            throw VirtusizeError.invalidPayload
        }

        return VirtusizeEvent(name: eventName, data: event["data"])
    }
}