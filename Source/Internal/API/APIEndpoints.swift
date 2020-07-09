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
    case productMetaDataHints
    case events
    case aoyama(region: AoyamaRegion)
    case storeViewApiKey
    case orders

    // MARK: - Properties

    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname

        switch self {
        case .productDataCheck(let externalId):
            components.path = (Virtusize.environment == .staging) ? "/stg/product/check" : "product/check"
            components.queryItems = dataCheckQueryItems(externalId: externalId)
            print(components)

        case .productMetaDataHints:
            components.path = "/rest-api/v1/product-meta-data-hints"

        case .events:
            components.path = "/a/api/v3/events"

        case .aoyama(let region):
            components.host = "static.api.virtusize.\(region.rawValue)"
            #if DEBUG
                components.path = "/a/aoyama/testing/sdk-integration/sdk-webview.html"
            #else
                components.path = "/a/aoyama/lastest/sdk-integration/sdk-webview.html"
            #endif

        case .storeViewApiKey:
            components.path = "/a/api/v3/stores/api-key/\(apiKey)"
            components.queryItems = storeViewApiKeyQueryItems()

        case .orders:
            components.path = "/a/api/v3/orders"
        }
        return components
    }

    var hostname: String {
        if case .productDataCheck = self {
            return Virtusize.environment.productDataCheckUrl()
        }
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

    /// Builds query parameters for the API endpoint `storeViewApiKey`
    ///
    /// - Returns: An array of query items for the `URLComponents`
    private func storeViewApiKeyQueryItems() -> [URLQueryItem] {
        var queryItem: [URLQueryItem] = []
        queryItem.append(URLQueryItem(name: "format", value: "json"))
        return queryItem
    }
}
