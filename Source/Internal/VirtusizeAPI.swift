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

	private class func hostname() -> String {
		let map = [
			"global": "www.virtusize.com",
			"japan": "api.virtusize.jp",
			"korea": "api.virtusize.kr",
			"staging": "staging.virtusize.com"
		]
		return map[Virtusize.environment] ?? "www.virtusize.com"
	}

	internal class func productCheck(externalId: String) -> URLRequest {
		guard let apiKey = Virtusize.APIKey else {
			fatalError("Please set Virtusize.APIKey")
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = hostname()
		components.path = "/integration/v3/product-data-check"
		components.queryItems = {
			var qi: [URLQueryItem] = []
			qi.append(URLQueryItem(name: "apiKey", value: apiKey))
			qi.append(URLQueryItem(name: "externalId", value: externalId))
			qi.append(URLQueryItem(name: "version", value: "1"))
			if let userID = Virtusize.userID {
				qi.append(URLQueryItem(name: "externalUserId", value: userID))
			}
			return qi
		}()

		guard let url = components.url else {
			fatalError("Compiler not feeling well today")
		}

        var request = URLRequest(url: url)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        request.httpMethod = "GET"
        return request
	}

	internal class func sendProductImage(url: URL, for externalId: String, jsonResult: JSONObject) -> URLRequest {
		guard let apiKey = Virtusize.APIKey else {
			fatalError("Please set Virtusize.APIKey")
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = hostname()
		components.path = "/integration/v3/product-meta-data-hints"
		components.queryItems = {
			var qi: [URLQueryItem] = []
			qi.append(URLQueryItem(name: "externalId", value: externalId))
			qi.append(URLQueryItem(name: "imageUrl", value: url.absoluteString))
			qi.append(URLQueryItem(name: "apiKey", value: apiKey))
			if let storeId = jsonResult["storeId"] as? Int {
            	qi.append(URLQueryItem(name: "storeId", value: String(storeId)))
			}
			return qi
		}()

		guard let url = components.url else {
			fatalError("Compiler not feeling well today")
		}

        var request = URLRequest(url: url)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        request.httpMethod = "POST"
        return request
	}

	internal class func sendEvent(name eventName: String, data eventData: Any?, previousJSONResult: JSONObject?) -> URLRequest? {
		guard let apiKey = Virtusize.APIKey else {
			fatalError("Please set Virtusize.APIKey")
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = hostname()
		components.path = "/a/api/v3/events"

        let screenSize = UIScreen.main.bounds.size
        var payloadData: [String: Any]  = [
            "name": eventName,
            "apiKey": apiKey,
            "type": "user",
            "source": "integration-ios",
            "userCohort": "direct",
            "widgetType": "mobile",
            "browserOrientation": UIDevice.current.orientation.isLandscape ? "landscape" : "portrait",
            "browserResolution": "\(Int(screenSize.height))x\(Int(screenSize.width))",
            "integrationVersion": String(VirtusizeVersionNumber),
            "snippetVersion": String(VirtusizeVersionNumber),
		]

		if let root = previousJSONResult,
        	let d = root["data"] as? JSONObject,
            let du = d["userData"] as? JSONObject {

			if let storeId = d["storeId"] {
            	payloadData["storeId"] = storeId
			}
            if let storeName = d["storeName"] {
                payloadData["storeName"] = storeName
            }
            if let storeProductType = d["productTypeName"] {
                payloadData["storeProductType"] = storeProductType
            }
            if let storeProductId = root["productId"] {
                payloadData["storeProductExternalId"] = storeProductId
            }
            if let wardrobeActive = du["wardrobeActive"] {
                payloadData["wardrobeActive"] = wardrobeActive
            }
            if let wardrobeHasM = du["wardrobeHasM"] {
                payloadData["wardrobeHasM"] = wardrobeHasM
            }
            if let wardrobeHasP = du["wardrobeHasP"] {
                payloadData["wardrobeHasP"] = wardrobeHasP
            }
            if let wardrobeHasR = du["wardrobeHasR"] {
                payloadData["wardrobeHasR"] = wardrobeHasR
            }
        }

		if let givenEventData = eventData as? [String: Any] {
			for (key, value) in givenEventData {
				if payloadData[key] == nil {
					payloadData[key] = value
				}
			}
		}

        let payloadJSONData: Data
		do {
			payloadJSONData = try JSONSerialization.data(withJSONObject: payloadData, options: [])
		}
		catch {
			return nil
		}

        var request = URLRequest(url: components.url!)
        request.addValue(BrowserID.current.identifier, forHTTPHeaderField: "x-vs-bid")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payloadJSONData
        return request
	}

	internal class func fitIllustratorURL(jsonResult: Any?) -> URLRequest? {
		let bid = BrowserID.current.identifier

		guard let rootObject = jsonResult as? JSONObject else {
			return nil
		}
		guard let dataObject = rootObject["data"] as? JSONObject else {
			return nil
		}

		guard let storeID = dataObject["storeId"] as? Int else {
			return nil
		}

		guard let productDataId = dataObject["productDataId"] as? Int else {
			return nil
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = hostname()
		components.path = "/a/fit-illustrator/v1/index.html"
		components.queryItems = {
			var qi: [URLQueryItem] = []
			qi.append(URLQueryItem(name: "detached", value: "false"))
			qi.append(URLQueryItem(name: "bid", value: bid))
			qi.append(URLQueryItem(name: "addToCartEnabled", value: "false"))
			qi.append(URLQueryItem(name: "storeId", value: String(storeID)))
			qi.append(URLQueryItem(name: "_", value: String(arc4random_uniform(1519982555))))
			qi.append(URLQueryItem(name: "spid", value: String(productDataId)))
			qi.append(URLQueryItem(name: "lang", value: Virtusize.language))
            qi.append(URLQueryItem(name: "ios", value: "true"))
            qi.append(URLQueryItem(name: "sdk", value: String(VirtusizeVersionNumber)))
			return qi
		}()

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return request
	}
}
