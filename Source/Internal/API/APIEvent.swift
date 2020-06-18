//
//  File.swift
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

typealias Payload = JSONObject

/// A structure to build the additional payload for the event to be sent to the server
/// and convert it from `JSONObject` to `Data`
internal struct APIEvent {
    /// The additional payload for the event as `Payload` (`JSONObject`)
    private var payload: Payload

    /// The name of the event
    let name: String

    /// Initializes the APIEvent structure
    init(withName name: String, apiKey: String) {
        self.name = name
        let screenSize = UIScreen.main.bounds.size

        self.payload = [
            "name": name,
            "apiKey": apiKey,
            "type": "user",
            "source": "integration-ios",
            "userCohort": "direct",
            "widgetType": "mobile",
            "browserOrientation": UIDevice.current.orientation.isLandscape ? "landscape" : "portrait",
            "browserResolution": "\(Int(screenSize.height))x\(Int(screenSize.width))",
            "integrationVersion": String(VirtusizeVersionNumber),
            "snippetVersion": String(VirtusizeVersionNumber)
        ]
    }

    /// Adds the response from Virtusize API for the `productDataCheck` request to payload
    ///
    /// - Parameter json: The product data from the response of the `productDataCheck` request
    mutating func align(withContext productDataCheck: JSONObject?) {
        guard let root = productDataCheck,
            let data = root["data"] as? JSONObject,
            let userData = data["userData"] as? JSONObject else {
                return
        }
        if let storeId = data["storeId"] {
            payload["storeId"] = storeId
        }
        if let storeName = data["storeName"] {
            payload["storeName"] = storeName
        }
        if let storeProductType = data["productTypeName"] {
            payload["storeProductType"] = storeProductType
        }
        if let storeProductId = root["productId"] {
            payload["storeProductExternalId"] = storeProductId
        }
        if let wardrobeActive = userData["wardrobeActive"] {
            payload["wardrobeActive"] = wardrobeActive
        }
        if let wardrobeHasM = userData["wardrobeHasM"] {
            payload["wardrobeHasM"] = wardrobeHasM
        }
        if let wardrobeHasP = userData["wardrobeHasP"] {
            payload["wardrobeHasP"] = wardrobeHasP
        }
        if let wardrobeHasR = userData["wardrobeHasR"] {
            payload["wardrobeHasR"] = wardrobeHasR
        }
    }

    /// Adds the additional data in the event to the payload
    ///
    /// - Parameter payload: The additional data in the event
    mutating func align(withPayload eventPayload: Payload?) {
        guard let payload = eventPayload else {
            return
        }
        for (key, value) in payload where self.payload[key] == nil {
            self.payload[key] = value
        }
    }

    /// The additional payload for the event as `Data`
    var jsonPayload: Data? {
        return try? JSONSerialization.data(withJSONObject: payload, options: [])
    }
}
