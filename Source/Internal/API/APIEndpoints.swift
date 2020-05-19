//
//  Endpoints.swift
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

/// This enum represents all available Virtusize endpoints
internal enum APIEndpoints {
    case productDataCheck(externalId: String)
    case productMetaDataHints(
        externalId: String,
        imageUrl: URL,
        storeId: Int?)
    case events
    case fitIllustrator(storeId: Int, productId: Int)

    // MARK: - Properties

    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname

        switch self {
        case .productDataCheck(let externalId):
            components.path = "/integration/v3/product-data-check"
            components.queryItems = dataCheckQueryItems(externalId: externalId)

        case .productMetaDataHints(let externalId, let imageUrl, let storeId):
            components.path = "/rest-api/v1/product-meta-data-hints"
            components.queryItems = metaDataHintsQueryItems(
                externalId: externalId,
                imageUrl: imageUrl,
                storeId: storeId)

        case .events:
            components.path = "/a/api/v3/events"

        case .fitIllustrator(let storeId, let productId):
            components.path = "/a/fit-illustrator/v1/index.html"
            components.queryItems = fitIllustratorQueryItems(
                storeId: storeId,
                productId: productId)
        }
        return components
    }

    var hostname: String {
        return Virtusize.environment.rawValue
    }

    var apiKey: String {
        guard let apiKey = Virtusize.APIKey else {
            fatalError("Please set Virtusize.APIKey")
        }
        return apiKey
    }

    // MARK: - Helper methods

    /// Builds query parameters for the API endpoint `productDataCheck`
    ///
    /// - Parameter externalId: A string to represent the id that will be used to reference
    ///  this product in Virtusize API
    /// - Returns: An array of query items for the `URLComponents`
    private func dataCheckQueryItems(externalId: String) -> [URLQueryItem] {
        var queryItem: [URLQueryItem] = []
        queryItem.append(URLQueryItem(name: "apiKey", value: apiKey))
        queryItem.append(URLQueryItem(name: "externalId", value: externalId))
        queryItem.append(URLQueryItem(name: "version", value: "1"))
        if let externalUserID = Virtusize.userID {
            queryItem.append(URLQueryItem(name: "externalUserId", value: externalUserID))
        }
        return queryItem
    }

    /// Builds query parameters for the API endpoint `productMetaDataHints`
    ///
    /// - Parameters:
    ///   - externalId: A string to represent the id that will be used to reference this product in Virtusize API
    ///   - imageUrl: The URL of the product image that is fully qualified with the domain and the protocol
    ///   - storeId: An integer that represents the store id from the product data
    /// - Returns: An array of query items for the `URLComponents`
    private func metaDataHintsQueryItems(externalId: String, imageUrl: URL, storeId: Int?) -> [URLQueryItem] {
        var queryItem: [URLQueryItem] = []
        let urlString = imageUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        queryItem.append(URLQueryItem(name: "apiKey", value: apiKey))
        queryItem.append(URLQueryItem(name: "externalId", value: externalId))
        queryItem.append(URLQueryItem(name: "imageUrl", value: urlString))
        if let storeId = storeId {
            queryItem.append(URLQueryItem(name: "storeId", value: String(storeId)))
        }
        return queryItem
    }

    /// Builds query parameters for the API endpoint `fitIllustrator`
    ///
    /// - Parameters:
    ///   - storeId: An integer that represents the store id from the product data
    ///   - productId: An Integer to represent the product id
    /// - Returns: An array of query items for the `URLComponents`
    private func fitIllustratorQueryItems(storeId: Int, productId: Int) -> [URLQueryItem] {
        let bid = BrowserID.current.identifier
        var queryItem: [URLQueryItem] = []
        queryItem.append(URLQueryItem(name: "detached", value: "false"))
        queryItem.append(URLQueryItem(name: "bid", value: bid))
        queryItem.append(URLQueryItem(name: "addToCartEnabled", value: "false"))
        queryItem.append(URLQueryItem(name: "storeId", value: String(storeId)))
        queryItem.append(URLQueryItem(name: "_", value: String(arc4random_uniform(1519982555))))
        queryItem.append(URLQueryItem(name: "spid", value: String(productId)))
        queryItem.append(URLQueryItem(name: "lang", value: Virtusize.language))
        queryItem.append(URLQueryItem(name: "ios", value: "true"))
        queryItem.append(URLQueryItem(name: "sdk", value: String(VirtusizeVersionNumber)))
        queryItem.append(URLQueryItem(name: "userId", value: Virtusize.userID))
        if let externalUserID = Virtusize.userID {
            queryItem.append(URLQueryItem(name: "externalUserId", value: externalUserID))
        }
        return queryItem
    }
}
