//
//  Deserializer.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

/// A structure that helps to deserialize the models specific to the Virtusize API
internal struct Deserializer {

    /// Gets `VirtusizeProduct` where the product data from the response of the `productDataCheck` request is added
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct`
    ///   - data: The product data from the response of the `productDataCheck` request.
    ///   If data is `nil`, the method returns `nil`.
    /// - Returns: `VirtusizeProduct` with the product data from the response of the `productDataCheck` request
    static func product(from product: VirtusizeProduct, withData data: Data?) -> VirtusizeProduct? {
        guard let data = data,
            let rootObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = rootObject as? JSONObject,
            let dataObject = root["data"] as? JSONObject else {
                NotificationCenter.default.post(name: Virtusize.productDataCheckDidFail,
                                                object: Virtusize.self,
                                                userInfo: ["message": "serialization failed"])
            return nil
        }

        // Send the API event where the user saw the product
        Virtusize.sendEvent(VirtusizeEvent(name: "user-saw-product"), withContext: root)

        var productCheckData: VirtusizeProductCheckData?

        if let data = try? JSONSerialization.data(withJSONObject: dataObject, options: .prettyPrinted) {
           productCheckData = try? JSONDecoder().decode(VirtusizeProductCheckData.self, from: data)
        }

        guard let isValid = productCheckData?.validProduct, isValid else {
            NotificationCenter.default.post(name: Virtusize.productDataCheckDidFail,
                                            object: Virtusize.self,
                                            userInfo: ["message": "product is not valid"])
            return nil
        }

        if let sendImageToBackend = productCheckData?.fetchMetaData,
            sendImageToBackend,
            product.imageURL != nil,
            let storeId = productCheckData?.storeId {
            Virtusize.sendProductImage(of: product, forStore: storeId)
        }

        // Send the API event where the user saw the widget button
        Virtusize.sendEvent(VirtusizeEvent(name: "user-saw-widget-button"), withContext: root)
        NotificationCenter.default.post(name: Virtusize.productDataCheckDidSucceed, object: Virtusize.self)

        // keep values of JSON response
        return VirtusizeProduct(
            externalId: product.externalId,
            imageURL: product.imageURL,
            productCheckData: productCheckData)
    }

    /// Gets `VirtusizeEvent` with the optional data to be sent to the Virtusize server
    ///
    /// - Parameter data: The optional data for the event
    /// - Throws: `VirtusizeError`
    /// - Returns: `VirtusizeEvent`
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

        guard let eventName: String = event["eventName"] as? String else {
            throw VirtusizeError.invalidPayload
        }

        return VirtusizeEvent(name: eventName, data: event["data"])
    }

    /// Gets `VirtusizeI18nLocalization` from the data response from the i18n request
    ///
    /// - Parameter data: The data for the localization texts
    /// - Returns: `VirtusizeI18nLocalization`
    static func i18n(data: Data?) -> VirtusizeI18nLocalization {
        let i18nLocalization = VirtusizeI18nLocalization()
        guard let data = data,
            let rootObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = rootObject as? JSONObject,
            let keysJSONObject = root["keys"] as? JSONObject,
            let appsJSONObject = keysJSONObject["apps"] as? JSONObject,
            let aoyamaJSONObject = appsJSONObject["aoyama"] as? JSONObject else {
                return i18nLocalization
        }

        let inpageJSONObject = aoyamaJSONObject["inpage"] as? JSONObject
        let detailsScreenJSONObject = aoyamaJSONObject["detailsScreen"] as? JSONObject
        let sizingJSONObject = detailsScreenJSONObject?["sizing"] as? JSONObject
        let itemBrandJSONObject = sizingJSONObject?["itemBrand"] as? JSONObject
        let mostBrandsJSONObject = sizingJSONObject?["mostBrands"] as? JSONObject
        let fitJSONObject = detailsScreenJSONObject?["fit"] as? JSONObject

        i18nLocalization.defaultText = trimI18nText(detailsScreenJSONObject?["defaultText"] as? String)
        i18nLocalization.defaultAccessoryText = trimI18nText(inpageJSONObject?["defaultAccessoryText"] as? String)

        i18nLocalization.sizingItemBrandLargeText = trimI18nText(itemBrandJSONObject?["large"] as? String)
        i18nLocalization.sizingItemBrandTrueText = trimI18nText(itemBrandJSONObject?["true"] as? String)
        i18nLocalization.sizingItemBrandSmallText = trimI18nText(itemBrandJSONObject?["small"] as? String)

        i18nLocalization.sizingMostBrandsLargeText = trimI18nText(mostBrandsJSONObject?["large"] as? String)
        i18nLocalization.sizingMostBrandsTrueText = trimI18nText(mostBrandsJSONObject?["true"] as? String)
        i18nLocalization.sizingMostBrandsSmallText = trimI18nText(mostBrandsJSONObject?["small"] as? String)

        i18nLocalization.fitLooseText = trimI18nText(fitJSONObject?["loose"] as? String)
        i18nLocalization.fitRegularText = trimI18nText(fitJSONObject?["regular"] as? String)
        i18nLocalization.fitTightText = trimI18nText(fitJSONObject?["tight"] as? String)

        return i18nLocalization
    }

    /// Trims the text from i18n
    private static func trimI18nText(_ text: String?) -> String {
        guard let text = text else {
            return ""
        }
        return text.replacingOccurrences(of: "%{boldStart}", with: "").replacingOccurrences(of: "%{boldEnd}", with: "")
    }
}
