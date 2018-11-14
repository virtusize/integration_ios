//
//  Virtusize.swift
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

public class Virtusize {

	public static var APIKey: String?

	public static var userID: String?

	public static var environment: String = "global"

    public static var language: String = Locale.preferredLanguages[0]

    public static var region: String = ""

	internal class func productCheck(
        externalId: String,
        _ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        let request = VirtusizeAPI.productCheck(externalId: externalId)
        let task = session.dataTask(
            with: request,
            completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
				DispatchQueue.main.async {
                	completionHandler(data, response, nil)
				}
            } else {
				DispatchQueue.main.async {
                	completionHandler(data, response, error)
				}
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

	internal class func sendProductImage(url: URL, for externalId: String, jsonResult: JSONObject) {
        let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        let request = VirtusizeAPI.sendProductImage(url: url, for: externalId, jsonResult: jsonResult)
        let task = session.dataTask(with: request)
        task.resume()
        session.finishTasksAndInvalidate()
	}

	internal class func sendEvent(name eventName: String, data eventData: Any?, previousJSONResult: JSONObject?) {
        let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let request = VirtusizeAPI.sendEvent(
            name: eventName,
            data: eventData,
            previousJSONResult: previousJSONResult) else {
        	return
        }
        let task = session.dataTask(with: request)
        task.resume()
        session.finishTasksAndInvalidate()
	}
}
