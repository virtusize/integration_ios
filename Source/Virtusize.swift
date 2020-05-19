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

/// The main class used by Virtusize clients to perform all available operations related to fit check
public class Virtusize {
    // MARK: - Properties

    /// The API key that is unique and provided for Virtusize clients
	public static var APIKey: String?

    /// The user id that is the unique user id from the client system
	public static var userID: String?

    /// The Virtusize environment that defaults to the `global` domain
	public static var environment = VirtusizeEnvironment.global

    /// The device language that defaults to the primary device language
    public static var language: String = Locale.preferredLanguages[0]

    /// NotificationCenter observers for debugging the initial product data check
    /// - `Virtusize.productDataCheckDidFail`, the `UserInfo` will contain a message
    /// with the cause of the failure
    /// - `Virtusize.productDataCheckDidSucceed`
    public static var productDataCheckDidFail = Notification.Name("VirtusizeProductDataCheckDidFail")
    public static var productDataCheckDidSucceed = Notification.Name("VirtusizeProductDataCheckDidSucceed")

    /// A default session configuration object for a URL session.
    private static let sessionConfiguration = URLSessionConfiguration.default

    /// A closure that is called when the operation completes
    typealias CompletionHandler = (Data?) -> Void

    // MARK: - Methods

    /// Performs an API request.
    ///
    /// - Parameters:
    ///   - request: A URL load request for an API request
    ///   - completionHandler: A callback to pass data back when an API request is successful
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

    /// The API request for product check
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct` for which check needs to be performed
    ///   - completionHandler: A callback to pass `VirtusizeProduct` back when an API request is successful
	internal class func productCheck(
        product: VirtusizeProduct,
        completion completionHandler: ((VirtusizeProduct?) -> Void)?) {
        perform(APIRequest.productCheck(product: product)) { data in
            completionHandler?(Deserializer.product(from: product, withData: data))
        }
    }

    /// The API request for sending image of VirtusizeProduct to the Virtusize server
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct` whose image needs to be sent to the Virtusize server
    ///   - storeId: An integer that represents the store id from the product data
    internal class func sendProductImage(of product: VirtusizeProduct, forStore storeId: Int) {
        guard let request = try? APIRequest.sendProductImage(of: product, forStore: storeId) else {
            return
        }
        perform(request)
	}

    /// The API request for logging an event and sending it to the Virtusize server
    ///
    /// - Parameters:
    ///   - event: An event to be sent to the Virtusize server
    ///   - context: The product data from the response of the `productDataCheck` request
    internal class func sendEvent(_ event: VirtusizeEvent, withContext context: JSONObject? = nil) {
        guard let request = APIRequest.sendEvent(event, withContext: context) else {
            return
        }
        perform(request)
	}
}
