//
//  VirtusizeAuthStringHelper.swift
//  VirtusizeAuth
//
//  Copyright (c) 2021-present Virtusize KK
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

internal class VirtusizeAuthStringHelper {
	/// Appends a JSON field to a string
	internal static func appendJsonFieldTo(jsonString: String, key: String, value: String) -> String {
		guard var jsonDict = getJsonDict(jsonString: jsonString) else {
			return jsonString
		}

		jsonDict[key] = value

		guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict),
			  let updatedJsonString = NSString(
				data: jsonData,
				encoding: String.Encoding.utf8.rawValue) as String? else {
			return jsonString
		}

		return updatedJsonString
	}

	/// Gets a dictionary from a JSON string
	internal static func getJsonDict(jsonString: String) -> [String: Any]? {
		guard let data = jsonString.data(using: .utf8),
			  let jsonDict = try? JSONSerialization.jsonObject(
				with: data,
				options: .allowFragments
			  ) as? [String: Any] else {
			return nil
		}

		return jsonDict
	}

	/// Updates a query parameter of a URL
	///
	/// - Parameters:
	///   - url: The URL to update
	///	  - key: The key of the query parameter to update
	///	  - value: The new value of the query parameter
	internal static func updateQueryParameterTo(urlString: String, name: String, value: String) -> String {
        guard var urlComponents = URLComponents(string: urlString) else {
			return urlString
		}

        var queryItems = urlComponents.queryItems ?? []

        if let itemIndex = queryItems.firstIndex(where: { $0.name == name }) {
			queryItems[itemIndex].value = value
        } else {
            queryItems.append(URLQueryItem(name: name, value: value))
        }

        urlComponents.queryItems = queryItems

		guard let updateUrlString =  urlComponents.url?.absoluteString else {
			return urlString
		}

		return updateUrlString
	}

    /// Removes the whole parameter from URL
    /// Specifics:
    /// - The logic is unique for the package and removes the whole parameter up to the next '&' symbols,
    ///   even if parameter contains '#'
    /// For example the URL "http://ex.com?foo=bar#3&code=2" will be reduced to "http://ex.com?code=2"
    /// where tranditional usage of `URLComponents` would lead to "http://ex.com?#3&code=2"
    internal static func removeParamFromUrl(url: String, paramName: String) -> String {
        guard let paramRange = url.range(of: paramName + "=") else {
            return url
        }
        var result = url
        if let endRange = url.range(of: "&", range: paramRange.upperBound..<url.endIndex) {
            result.removeSubrange(paramRange.lowerBound...endRange.lowerBound)
        } else {
            // this is the last parameter
            result.removeSubrange(paramRange.lowerBound...)
            result.removeLast() // don't forget to remove preivous '?' or '&' symbol
        }
        return result
    }

	internal static func getRedirectUrl(region: String?, env: String?) -> String {
		return "https://static.api.virtusize.\(region ?? "com")/a/sns-proxy/\(env ?? "production")/sns-auth.html"
	}
}
