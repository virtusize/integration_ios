//
//  Endpoints.swift
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

/// This enum represents all available Virtusize endpoints
internal enum APIEndpoints {
    case productDataCheck(externalId: String)
    case productMetaDataHints
    case events
    case virtusize(region: VirtusizeRegion)
    case storeViewApiKey
    case orders

    // MARK: - Properties

    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname

        switch self {
        case .productDataCheck(let externalId):
            components.path = (Virtusize.environment == .staging) ? "/stg/product/check" : "/product/check"
            components.queryItems = dataCheckQueryItems(externalId: externalId)

        case .productMetaDataHints:
            components.path = "/rest-api/v1/product-meta-data-hints"

        case .events:
            components.path = "/a/api/v3/events"

        case .virtusize(let region):
            components.host = "static.api.virtusize.\(region.rawValue)"
            components.path = "/a/aoyama/latest/sdk-integration/sdk-webview.html"

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

    /// Builds query parameters for the API endpoint `storeViewApiKey`
    ///
    /// - Returns: An array of query items for the `URLComponents`
    private func storeViewApiKeyQueryItems() -> [URLQueryItem] {
        var queryItem: [URLQueryItem] = []
        queryItem.append(URLQueryItem(name: "format", value: "json"))
        return queryItem
    }
}
