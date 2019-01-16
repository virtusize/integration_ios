//
//  APIRequest.swift
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

private enum APIMethod: String {
    case get = "GET", post = "POST"
}

internal struct APIRequest {
    private static func HTTPRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
        guard let url = components.url else {
            fatalError("Endpoint URL components creation failed")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }

    private static func apiRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
        var request = HTTPRequest(components: components, method: method)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        return request
    }

    private static func apiRequest(components: URLComponents, withPayload payload: Data) -> URLRequest {
        var request = apiRequest(components: components, method: .post)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        return request
    }

	internal static func productCheck(product: VirtusizeProduct) -> URLRequest {
        let endpoint = APIEndpoints.productDataCheck(externalId: product.externalId)
        return apiRequest(components: endpoint.components)
	}

    internal static func sendProductImage(of product: VirtusizeProduct, forStore storeId: Int) throws -> URLRequest {
        guard let imageURL = product.imageURL else {
            fatalError("Image url is not defined")
        }

        let endpoint = APIEndpoints.productMetaDataHints(
            externalId: product.externalId,
            imageUrl: imageURL,
            storeId: storeId)
        return apiRequest(components: endpoint.components, method: .post)
	}

	internal static func sendEvent(
        _ virtusizeEvent: VirtusizeEvent, withContext context: JSONObject?) -> URLRequest? {
        let endpoint = APIEndpoints.events

        var event = APIEvent(withName: virtusizeEvent.name, apiKey: endpoint.apiKey)
        event.align(withContext: context)
        event.align(withPayload: virtusizeEvent.data as? [String: Any])

        guard let payloadData = event.jsonPayload else {
            return nil
        }
        return apiRequest(components: endpoint.components, withPayload: payloadData)
	}

	internal static func fitIllustratorURL(in context: Any?) -> URLRequest? {
		guard let rootObject = context as? JSONObject,
            let dataObject = rootObject["data"] as? JSONObject,
            let storeId = dataObject["storeId"] as? Int,
            let productId = dataObject["productDataId"] as? Int else {
			return nil
		}

        let endpoint = APIEndpoints.fitIllustrator(storeId: storeId, productId: productId)
        return HTTPRequest(components: endpoint.components)
	}
}
