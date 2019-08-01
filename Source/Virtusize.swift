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
	public static var environment = VirtusizeEnvironment.global
    // Default to the language set fot the phone
    public static var language: String = Locale.preferredLanguages[0]
    // `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
    // with the cause of the failure
    public static var productDataCheckDidFail = Notification.Name("VirtusizeProductDataCheckDidFail")
    public static var productDataCheckDidSucceed = Notification.Name("VirtusizeProductDataCheckDidSucceed")
    private static let sessionConfiguration = URLSessionConfiguration.default

    typealias CompletionHandler = (Data?) -> Void

    private class func perform(_ request: URLRequest, completion completionHandler: CompletionHandler? = nil) {
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        let task: URLSessionDataTask
        if let completionHandler = completionHandler {
            task = session.dataTask(
                with: request) { (data, _, _) in
                DispatchQueue.main.async {
                    completionHandler(data)
                }
            }
        } else {
            task = session.dataTask(with: request)
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }

	internal class func productCheck(
        product: VirtusizeProduct,
        completion completionHandler: ((VirtusizeProduct?) -> Void)?) {
        perform(APIRequest.productCheck(product: product)) { data in
            completionHandler?(Deserializer.product(from: product, withData: data))
        }
    }

    internal class func sendProductImage(of product: VirtusizeProduct, forStore storeId: Int) {
        guard let request = try? APIRequest.sendProductImage(of: product, forStore: storeId) else {
            return
        }
        perform(request)
	}

    internal class func sendEvent(_ event: VirtusizeEvent, withContext context: JSONObject? = nil) {
        guard let request = APIRequest.sendEvent(event, withContext: context) else {
            return
        }
        perform(request)
	}
}
