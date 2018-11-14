//
//  VirtusizeAPI.swift
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

internal typealias JSONObject = [String: Any]
internal typealias JSONArray = [JSONObject]

internal class VirtusizeAPI {
    private enum Endpoints {
        case productDataCheck(externalId: String)
        case productMetaDataHints(
            externalId: String,
            url: URL,
            storeId: Int?)
        case events
        case fitIllustrator(storeId: Int, productId: Int)

        var components: URLComponents {
            var components = URLComponents()
            components.scheme = "https"
            components.host = hostname

            switch self {
            case .productDataCheck(let externalId):
                components.path = "/integration/v3/product-data-check"
                components.queryItems = dataCheckQueryItems(externalId: externalId)

            case .productMetaDataHints(let externalId, let url, let storeId):
                components.path = "/integration/v3/product-meta-data-hints"
                components.queryItems = metaDataHintsQueryItems(
                    externalId: externalId,
                    url: url,
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
            let map = [
                "global": "www.virtusize.com",
                "japan": "api.virtusize.jp",
                "korea": "api.virtusize.kr",
                "staging": "staging.virtusize.com"
            ]
            return map[Virtusize.environment] ?? "www.virtusize.com"
        }

        var apiKey: String {
            guard let apiKey = Virtusize.APIKey else {
                fatalError("Please set Virtusize.APIKey")
            }
            return apiKey
        }

        private func dataCheckQueryItems(externalId: String) -> [URLQueryItem] {
            var queryItem: [URLQueryItem] = []
            queryItem.append(URLQueryItem(name: "apiKey", value: apiKey))
            queryItem.append(URLQueryItem(name: "externalId", value: externalId))
            queryItem.append(URLQueryItem(name: "version", value: "1"))
            if let userID = Virtusize.userID {
                queryItem.append(URLQueryItem(name: "externalUserId", value: userID))
            }
            return queryItem
        }

        private func metaDataHintsQueryItems(externalId: String, url: URL, storeId: Int?) -> [URLQueryItem] {
            var queryItem: [URLQueryItem] = []
            queryItem.append(URLQueryItem(name: "apiKey", value: apiKey))
            queryItem.append(URLQueryItem(name: "externalId", value: externalId))
            queryItem.append(URLQueryItem(name: "imageUrl", value: url.absoluteString))
            if let storeId = storeId {
                queryItem.append(URLQueryItem(name: "storeId", value: String(storeId)))
            }
            return queryItem
        }

        private func fitIllustratorQueryItems(storeId: Int, productId: Int) -> [URLQueryItem] {
            let bid = BrowserID.current.identifier
            var queryItem: [URLQueryItem] = []
            queryItem.append(URLQueryItem(name: "detached", value: "false"))
            queryItem.append(URLQueryItem(name: "bid", value: bid))
            queryItem.append(URLQueryItem(name: "addToCartEnabled", value: "false"))
            queryItem.append(URLQueryItem(name: "storeId", value: String(storeId)))
            queryItem.append(URLQueryItem(name: "_", value: String(arc4random_uniform(1519982555))))
            queryItem.append(URLQueryItem(name: "spid", value: String(storeId)))
            queryItem.append(URLQueryItem(name: "lang", value: Virtusize.language))
            queryItem.append(URLQueryItem(name: "ios", value: "true"))
            queryItem.append(URLQueryItem(name: "sdk", value: String(VirtusizeVersionNumber)))
            queryItem.append(URLQueryItem(name: "userId", value: Virtusize.userID))
            if let userID = Virtusize.userID {
                queryItem.append(URLQueryItem(name: "externalUserId", value: userID))
            }
            return queryItem
        }
    }

    private enum Method: String {
        case get = "GET", post = "POST"
    }

    typealias Payload = [String: Any]

    private struct Event {
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

        mutating func align(withJSON json: JSONObject?) {
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

    private class func apiRequest(components: URLComponents, method: Method = .get) -> URLRequest {
        guard let url = components.url else {
            fatalError("Endpoint URL components creation failed")
        }

        var request = URLRequest(url: url)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        request.httpMethod = method.rawValue
        return request
    }

    private class func apiRequest(components: URLComponents, withPayload payload: Data) -> URLRequest {
        var request = apiRequest(components: components, method: .post)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        return request
    }

	internal class func productCheck(externalId: String) -> URLRequest {
        let endpoint = Endpoints.productDataCheck(externalId: externalId)
        return apiRequest(components: endpoint.components)
	}

	internal class func sendProductImage(url: URL, for externalId: String, jsonResult: JSONObject) -> URLRequest {
        let endpoint = Endpoints.productMetaDataHints(
            externalId: externalId,
            url: url,
            storeId: jsonResult["storeId"] as? Int)
        return apiRequest(components: endpoint.components, method: .post)
	}

	internal class func sendEvent(
        name eventName: String,
        data eventData: Any?,
        previousJSONResult json: JSONObject?) -> URLRequest? {
        let endpoint = Endpoints.events
        var event = Event(withName: eventName, apiKey: endpoint.apiKey)
        event.align(withJSON: json)
        event.align(withPayload: eventData as? [String: Any])

        guard let payloadData = event.jsonPayload else {
            return nil
        }
        return apiRequest(components: endpoint.components, withPayload: payloadData)
	}

	internal class func fitIllustratorURL(jsonResult: Any?) -> URLRequest? {
		guard let rootObject = jsonResult as? JSONObject,
            let dataObject = rootObject["data"] as? JSONObject,
            let storeId = dataObject["storeId"] as? Int,
            let productId = dataObject["productId"] as? Int else {
			return nil
		}

        let endpoint = Endpoints.fitIllustrator(storeId: storeId, productId: productId)
        return apiRequest(components: endpoint.components)
	}
}
