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

/// This enum contains supported HTTP request methods
private enum APIMethod: String {
    case get = "GET", post = "POST"
}

/// A structure to get `URLRequest`s for Virtusize API requests
internal struct APIRequest {
    /// Gets a `URLRequest` for a HTTP request
    ///
    /// - Parameters:
    ///   - components: `URLComponents` to obtain the `URL`
    ///   - method: An `APIMethod` that defaults to the `GET` HTTP method
    /// - Returns: A `URLRequest` for this HTTP request
    private static func HTTPRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
        guard let url = components.url else {
            fatalError("Endpoint URL components creation failed")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }

    /// Gets the `URLRequest` for the HTTP request where the Browser Identifier is added
    ///
    /// - Parameters:
    ///   - components: `URLComponents` to obtain the `URL`
    ///   - method: An `APIMethod` that defaults to the `GET` HTTP method
    /// - Returns: A `URLRequest` for this HTTP request
    private static func apiRequest(components: URLComponents, method: APIMethod = .get) -> URLRequest {
        var request = HTTPRequest(components: components, method: method)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        return request
    }

    /// Gets the `URLRequest` for the HTTP request where the request body is added
    ///
    /// - Parameters:
    ///   - components: `URLComponents` to obtain the `URL`
    ///   - payload: A `Data` that is sent as the message body of the request
    /// - Returns: A `URLRequest` for this HTTP request
    private static func apiRequest(components: URLComponents, withPayload payload: Data) -> URLRequest {
        var request = apiRequest(components: components, method: .post)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        return request
    }

    /// Gets the `URLRequest` for the `productCheck` request
    ///
    /// - Parameter product: `VirtusizeProduct` for which check needs to be performed
    /// - Returns: A `URLRequest` for the `productCheck` request
	internal static func productCheck(product: VirtusizeProduct) -> URLRequest {
        let endpoint = APIEndpoints.productDataCheck(externalId: product.externalId)
        return apiRequest(components: endpoint.components)
	}

    /// Gets the `URLRequest` for the `productMetaDataHints` request to send the image of
    /// VirtusizeProduct to the Virtusize server
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct` for which check needs to be performed
    ///   - storeId: An integer that represents the store id from the product data
    /// - Returns: A `URLRequest` for the `productMetaDataHints` request
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

    /// Gets the `URLRequest` for the `sendEvent` request
    ///
    /// - Parameters:
    ///   - virtusizeEvent: An event to be sent to the Virtusize server
    ///   - context: The product data from the response of the `productDataCheck` request
    /// - Returns: A `URLRequest` for the `sendEvent` request
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

    /// Gets the `URLRequest` for the `fitIllustrator` request
    ///
    /// - Parameter context: The product data from the response of the `productDataCheck` request
    /// - Returns: A `URLRequest` for the `fitIllustrator` request
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

    /// Gets the `URLRequest` for the `storeViewApiKey` request
    ///
    /// - Returns: A `URLRequest` for the `storeViewApiKey` request
    internal static func retrieveStoreInfo() -> URLRequest? {
        let endpoint = APIEndpoints.storeViewApiKey
        return apiRequest(components: endpoint.components)
    }

    /// Gets the `URLRequest` for the `orders` request
    ///
    /// - Parameter order: A `VirtusizeOrder` that includes the info of the order and the items that the user purchased
    /// - Returns: A `URLRequest` for the `orders` request
    internal static func sendOrder(_ order: VirtusizeOrder) -> URLRequest? {
        guard let jsonData = try? JSONEncoder().encode(order) else {
            return nil
        }
        let endpoint = APIEndpoints.orders
        return apiRequest(components: endpoint.components, withPayload: jsonData)
    }
}
