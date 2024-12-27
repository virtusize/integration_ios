//
//  APIEndpoints.swift
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

import Foundation

/// This enum represents all available Virtusize endpoints
internal enum APIEndpoints {
	case productCheck(externalId: String)
	case productMetaDataHints
	case events
    case latestAoyamaVersion
    case virtusizeWebView(version: String)
    case virtusizeWebViewForSpecificClients
	case storeViewApiKey
	case orders
	case storeProducts(productId: Int)
	case productTypes
	case sessions
	case user
	case userProducts
	case userBodyMeasurements
	case getSize
	case i18n(langCode: String)

    // MARK: - Properties
    var hostname: String {
		// swiftlint:disable switch_case_alignment
        switch self {
            case .productCheck:
                return Virtusize.environment.servicesUrl()
            case  .getSize:
                return Virtusize.environment.getSizeUrl()
            case .latestAoyamaVersion, .virtusizeWebView, .virtusizeWebViewForSpecificClients:
                return Virtusize.environment.virtusizeStaticApiUrl()
            case .i18n:
                return Virtusize.environment.i18nUrl()
            case .events:
                return Virtusize.environment.eventApiUrl()
            default:
                return Virtusize.environment.rawValue
        }
		// swiftlint:enable switch_case_alignment
    }

    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname
		// swiftlint:disable switch_case_alignment
        switch self {
            case .productCheck(let externalId):
                let envPathForServicesAPI = Virtusize.environment.isProdEnv ? "" : "/stg"
                components.path = "\(envPathForServicesAPI)/product/check"
                components.queryItems = dataCheckQueryItems(externalId: externalId)

            case .productMetaDataHints:
                components.path = "/rest-api/v1/product-meta-data-hints"

            case .events:
                break

            case .latestAoyamaVersion:
                components.path = "/a/aoyama/latest.txt"

            case .virtusizeWebView(let version):
                components.path = "/a/aoyama/\(version)/sdk-webview.html"

            case .virtusizeWebViewForSpecificClients:
                components.path = "/a/aoyama/testing/privacy-policy-phase2-vue/sdk-webview.html"

            case .storeViewApiKey:
                components.path = "/a/api/v3/stores/api-key/\(apiKey)"
                components.queryItems = jsonFormatQueryItems()

            case .orders:
                components.path = "/a/api/v3/orders"

            case .storeProducts(let productId):
                components.path = "/a/api/v3/store-products/\(productId)"
                components.queryItems = jsonFormatQueryItems()

            case .productTypes:
                components.path = "/a/api/v3/product-types"

            case .sessions:
                components.path = "/a/api/v3/sessions"

            case .user:
                components.path = "/a/api/v3/users/me"

            case .userProducts:
                components.path = "/a/api/v3/user-products"

            case .userBodyMeasurements:
                components.path = "/a/api/v3/user-body-measurements"

            case .getSize:
                components.path =  "/item"

            case .i18n(let langCode):
                components.path = "/bundle-payloads/aoyama/\(langCode)"
        }
		// swiftlint:enable switch_case_alignment

        return components
    }

	var apiKey: String {
		guard let apiKey = Virtusize.APIKey else {
			fatalError("Please set Virtusize.APIKey")
		}
		return apiKey
	}

	// MARK: - Helper methods

	/// Builds query parameters for the API endpoint `productCheck`
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

	/// Gets an array of query items with the name "format" whose key is "json"
	///
	/// - Returns: An array of query items for the `URLComponents`
	private func jsonFormatQueryItems() -> [URLQueryItem] {
		var queryItem: [URLQueryItem] = []
		queryItem.append(URLQueryItem(name: "format", value: "json"))
		return queryItem
	}
}
