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

internal struct APIEvent {
    private var payload: Payload
    let name: String

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

    mutating func align(withContext json: JSONObject?) {
        guard let root = json,
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

    mutating func align(withPayload payload: Payload?) {
        guard let payload = payload else {
            return
        }
        for (key, value) in payload where self.payload[key] == nil {
            self.payload[key] = value
        }
    }

    var jsonPayload: Data? {
        return try? JSONSerialization.data(withJSONObject: payload, options: [])
    }
}
