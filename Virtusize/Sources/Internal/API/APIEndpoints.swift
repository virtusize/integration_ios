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
	case getItemSizeRecommendation
    case getShoeSizeRecommendation
	case i18n(langCode: String)
	case storeI18n(storeName: String)

    // MARK: - Properties
    var hostname: String {
		switch self {
        case .productCheck:
            return Virtusize.environment.servicesUrl()

        case .productTypes, .storeProducts:
            if Virtusize.params?.serviceEnvironment == true {
                return Virtusize.environment.servicesUrl()
            } else {
                return Virtusize.environment.rawValue
            }

		case .getItemSizeRecommendation:
			return Virtusize.environment.getSizeUrl()
        case .getShoeSizeRecommendation:
            return Virtusize.environment.getSizeUrl()
		case .latestAoyamaVersion, .virtusizeWebView, .virtusizeWebViewForSpecificClients:
			return Virtusize.environment.virtusizeStaticApiUrl()
		case .i18n:
			return Virtusize.environment.i18nUrl()
		case .events:
			return Virtusize.environment.eventApiUrl()
		case .storeI18n:
			return Virtusize.environment.integrationUrl()
		default:
			return Virtusize.environment.rawValue
		}
    }

    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname
		switch self {
		case .productCheck(let externalId):
			// Store local copy to avoid repeated access during string interpolation
			let isProd = Virtusize.environment.isProdEnv
			let envPathForServicesAPI = isProd ? "" : "/stg"
			components.path = "\(envPathForServicesAPI)/product/check"
			components.queryItems = dataCheckQueryItems(externalId: externalId)

		case .productMetaDataHints:
			components.path = "/rest-api/v1/product-meta-data-hints"

		case .events:
			break

		case .latestAoyamaVersion:
			components.path = "/a/aoyama/latest.txt"

		case .virtusizeWebView(let version):
			let branch = Virtusize.params?.branch
			switch branch {
			case .none:
				components.path = "/a/aoyama/\(version)/sdk-webview.html"
			case .some("staging"):
				components.path = "/a/aoyama/staging/sdk-webview.html"
			case .some(let branchName):
				components.path = "/a/aoyama/testing/\(branchName)/sdk-webview.html"
			}

		case .virtusizeWebViewForSpecificClients:
			let branch = Virtusize.params?.branch
			switch branch {
			case .none:
				components.path = "/a/aoyama/testing/privacy-policy-phase2-vue/sdk-webview.html"
			case .some("staging"):
				components.path = "/a/aoyama/staging/sdk-webview.html"
			case .some(let branchName):
				components.path = "/a/aoyama/testing/\(branchName)/sdk-webview.html"
			}

		case .storeViewApiKey:
			components.path = "/a/api/v3/stores/api-key/\(apiKey)"
			components.queryItems = jsonFormatQueryItems()

		case .orders:
			components.path = "/a/api/v3/orders"

		case .storeProducts(let productId):
			// Store local copy to avoid repeated access during string interpolation
			let isProd = Virtusize.environment.isProdEnv
            let hasServiceEnvironment = Virtusize.params?.serviceEnvironment == true
            let envPathForServicesAPI = !isProd && hasServiceEnvironment ? "/stg" : ""
			components.path = "\(envPathForServicesAPI)/a/api/v3/store-products/\(productId)"
			components.queryItems = jsonFormatQueryItems()

		case .productTypes:
			// Store local copy to avoid repeated access during string interpolation
			let isProd = Virtusize.environment.isProdEnv
            let hasServiceEnvironment = Virtusize.params?.serviceEnvironment == true
            let envPathForServicesAPI = !isProd && hasServiceEnvironment ? "/stg" : ""
			components.path = "\(envPathForServicesAPI)/a/api/v3/product-types"

		case .sessions:
			components.path = "/a/api/v3/sessions"

		case .user:
			components.path = "/a/api/v3/users/me"

		case .userProducts:
			components.path = "/a/api/v3/user-products"

		case .userBodyMeasurements:
			components.path = "/a/api/v3/user-body-measurements"

		case .getItemSizeRecommendation:
			components.path =  "/item"

		case .getShoeSizeRecommendation:
			components.path =  "/shoe"

		case .i18n(let langCode):
			components.path = "/bundle-payloads/aoyama/\(langCode)"

		case .storeI18n(let storeName):
			// Store local copies to avoid repeated access during string interpolation
			let isProd = Virtusize.environment.isProdEnv
			let envPath = isProd ? "/production" : "/staging"
			let storeNameValue = storeName.isEmpty ? "unknown" : storeName
			components.path = "\(envPath)/\(storeNameValue)/customText.json"

		}
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
