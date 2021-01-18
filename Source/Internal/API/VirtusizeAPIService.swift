//
//  VirtusizeAPIService.swift
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

internal class VirtusizeAPIService {

	/// A closure that is called when the operation completes
	typealias CompletionHandler = (Data?) -> Void

	/// A closure that is called when the operation fails
	typealias ErrorHandler = (VirtusizeError) -> Void

	/// A default session configuration object for a URL session.
	private static let sessionConfiguration = URLSessionConfiguration.default

	/// A session that confirms to `APISessionProtocol` for mocking API responses in testing
	internal static var session: APISessionProtocol = URLSession(
		configuration: sessionConfiguration,
		delegate: nil,
		delegateQueue: nil)

	/// Performs an API request.
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - completionHandler: A callback to pass data back when an API request is successful
	///   - error: A callback to pass `VirtusizeError` back when an API request is unsuccessful
	private static func perform(_ request: URLRequest,
								completion completionHandler: CompletionHandler? = nil,
								error errorHandler: ErrorHandler? = nil) {
		let task: URLSessionDataTask
		task = VirtusizeAPIService.session.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				DispatchQueue.main.async {
					errorHandler?(VirtusizeError.apiRequestError(request.url, error!.localizedDescription))
				}
				return
			}

			if let httpResponse = response as? HTTPURLResponse, !httpResponse.isSuccessful() {
				var errorDebugDescription = "Unknown Error"
				if let data = data {
					errorDebugDescription = String(decoding: data, as: UTF8.self)
				}
				DispatchQueue.main.async {
					errorHandler?(VirtusizeError.apiRequestError(request.url, errorDebugDescription))
				}
			} else {
				DispatchQueue.main.async {
					completionHandler?(data)
				}
			}
		}
		task.resume()
		URLSession.shared.finishTasksAndInvalidate()
	}

	/// Gets the result of an API request
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - onSuccess: A callback to pass back the data in a generic type when an API request is successful
	///   - onError: A callback to pass `VirtusizeError` back when an API request is unsuccessful
	private static func getAPIResult<T: Decodable>(
		request: URLRequest,
		onSuccess: ((T) -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) {
		perform(request, completion: { data in
			guard let data = data else {
				return
			}
			do {
				let result = try JSONDecoder().decode(T.self, from: data)
				onSuccess?(result)
			} catch {
				onError?(VirtusizeError.jsonDecodingFailed(String(describing: T.self), error))
			}
		}, error: { error in
			onError?(error)
		})
	}

	/// Performs an API request asynchronously
	///
	/// - Parameter request: A URL load request for an API request
	/// - Returns the `APIResponse`
	private static func performAsync(_ request: URLRequest) -> APIResponse? {
		var apiResponse: APIResponse?
		let semaphore = DispatchSemaphore(value: 0)
		let task: URLSessionDataTask
		task = VirtusizeAPIService.session.dataTask(with: request) { (data, response, error) in
			apiResponse = APIResponse(data: data, response: response, error: error)
			semaphore.signal()
		}
		task.resume()
		URLSession.shared.finishTasksAndInvalidate()

		_ = semaphore.wait(timeout: .distantFuture)

		guard apiResponse != nil else {
			return apiResponse
		}

		guard apiResponse!.error == nil else {
			apiResponse!.virtusizeError = VirtusizeError.apiRequestError(
			request.url,
			apiResponse!.error!.localizedDescription
			)
			return apiResponse
		}

		if let httpResponse = apiResponse!.response as? HTTPURLResponse, !httpResponse.isSuccessful() {
			var errorDebugDescription = "Unknown Error"
			if let data = apiResponse?.data {
				errorDebugDescription = String(decoding: data, as: UTF8.self)
			}
			apiResponse!.virtusizeError = VirtusizeError.apiRequestError(request.url, errorDebugDescription)
		}
		return apiResponse
	}

	/// Gets the result of an asynchronous API request
	///
	/// - Parameters:
	///   - request: A URL load request for an API request
	///   - type: The API result data in the generic type
	private static func getAPIResultAsync<T: Decodable>(request: URLRequest, type: T.Type) -> APIResult<T> {
		let apiResponse = performAsync(request)
		guard apiResponse?.virtusizeError == nil,
			  let data = apiResponse?.data else {
			return .failure(apiResponse?.virtusizeError)
		}

		do {
			let result = try JSONDecoder().decode(type, from: data)
			let jsonString = String(data: data, encoding: String.Encoding.utf8)
			return .success(result, jsonString)
		} catch {
			return .failure(VirtusizeError.jsonDecodingFailed(String(describing: type), error))
		}
	}

	/// The API request for product check
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` for which check needs to be performed
	///   - completionHandler: A callback to pass `VirtusizeProduct` back when an API request is successful
	internal static func productCheck(product: VirtusizeProduct,
									  completion completionHandler: ((VirtusizeProduct?) -> Void)?,
									  failure: ((VirtusizeError) -> Void)? = nil) {
		perform(APIRequest.productCheck(product: product), completion: { data in
			completionHandler?(Deserializer.product(from: product, withData: data))
		}, error: { error in
			failure?(error)
		})
	}

	/// The API request for sending image of VirtusizeProduct to the Virtusize server
	///
	/// - Parameters:
	///   - product: `VirtusizeProduct` whose image needs to be sent to the Virtusize server
	///   - storeId: An integer that represents the store id from the product data
	internal static func sendProductImage(
		of product: VirtusizeProduct,
		forStore storeId: Int,
		completion completionHandler: ((JSONObject?) -> Void)? = nil
	) {
		guard let request = try? APIRequest.sendProductImage(of: product, forStore: storeId) else {
			return
		}
		VirtusizeAPIService.perform(request, completion: { data in
			guard let data = data else {
				return
			}
			let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
			completionHandler?(jsonObject)
		})
	}

	/// The API request for logging an event and sending it to the Virtusize server
	///
	/// - Parameters:
	///   - event: An event to be sent to the Virtusize server
	///   - context: The product data from the response of the `productDataCheck` request
	internal static func sendEvent(
		_ event: VirtusizeEvent,
		withContext context: JSONObject? = nil,
		completion completionHandler: ((JSONObject?) -> Void)? = nil
	) {
		guard let request = APIRequest.sendEvent(event, withContext: context) else {
			return
		}
		VirtusizeAPIService.perform(request, completion: { data in
			guard let data = data else {
				return
			}
			let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
			completionHandler?(jsonObject)
		})
	}

	/// The API request for retrieving the specific store info from the API key
	/// that is unique to the client
	///
	/// - Parameters:
	///   - completion: A callback to pass the region value of `VirtusizeStore` back when the request to
	///   retrieve the store info is successful
	///   - errorHandler: A callback to pass `VirtusizeError` back when the request to retrieve the
	///   store info is unsuccessful
	internal static func retrieveStoreInfo(
		completion: @escaping (_ region: String?) -> Void,
		errorHandler: ((VirtusizeError) -> Void)? = nil
	) {
		guard let request = APIRequest.retrieveStoreInfo() else {
			return
		}
		VirtusizeAPIService.perform(request, completion: { data in
			guard let data = data else {
				return
			}
			do {
				let store = try JSONDecoder().decode(VirtusizeStore.self, from: data)
				completion(store.region ?? "JP")
			} catch {
				errorHandler?(VirtusizeError.jsonDecodingFailed("VirtusizeStore", error))
			}
		}, error: { error in
			errorHandler?(error)
		})
	}

	/// The API request for sending an order to the server
	///
	/// - Parameters:
	///   - order: An order to be send to the server
	///   - onSuccess: A callback to be called when the request to send an order is successful
	///   - onError: A callback to pass `VirtusizeError` back when the request to send an order is
	///    unsuccessful
	internal static func sendOrder(
		userID: String?,
		_ order: VirtusizeOrder,
		onSuccess: (() -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil
	) {
		guard let externalUserId = userID else {
			fatalError("Please set Virtusize.userID")
		}
		var mutualOrder = order
		mutualOrder.externalUserId = externalUserId

		VirtusizeAPIService.retrieveStoreInfo(completion: { region in
			mutualOrder.region = region
			VirtusizeAPIService.sendOrderWithRegion(mutualOrder, onSuccess: onSuccess, onError: onError)
		}, errorHandler: { error in
			onError?(error)
		})
	}

	/// Helper function for sending order after making the request to retrieve the store info
	internal static func sendOrderWithRegion(
		_ order: VirtusizeOrder,
		onSuccess: (() -> Void)? = nil,
		onError: ((VirtusizeError) -> Void)? = nil) {
		guard let request = APIRequest.sendOrder(order) else {
			return
		}
		perform(request, completion: { _ in
			onSuccess?()
		}, error: { error in
			onError?(error)
		})
	}

	/// The API request for getting the store product info from the Virtusize server
	///
	/// - Parameters:
	///   - productId: The internal product ID from the Virtusize server
	/// - Return:
	internal static func getStoreProductInfoAsync(productId: Int) -> APIResult<VirtusizeInternalProduct> {
		guard let request = APIRequest.getStoreProductInfo(productId: productId) else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: VirtusizeInternalProduct.self)
	}

	/// The API request for getting the list of all the product types from the Virtusize server
	///
	/// - Parameters:
	///   - onSuccess: A callback to pass the list of `VirtusizeProductType` when the request is successful
	///   - onError: A callback to pass `VirtusizeError` back when the request is unsuccessful
	internal static func getProductTypesAsync() -> APIResult<[VirtusizeProductType]> {
		guard let request = APIRequest.getProductTypes() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: [VirtusizeProductType].self)
	}

	/// The API request for getting the user session data from the Virtusize server
	///
	/// - Returns: the user session data in the type of `UserSessionInfo`
	internal static func getUserSessionInfoAsync() -> APIResult<UserSessionInfo> {
		guard let request = APIRequest.getSessions() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: UserSessionInfo.self)
	}

	/// The API request for getting the list of user products from the Virtusize server
	///
	/// - Returns: the user product data in the type of `VirtusizeInternalProduct`
	internal static func getUserProductsAsync() -> APIResult<[VirtusizeInternalProduct]> {
		guard let request = APIRequest.getUserProducts() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: [VirtusizeInternalProduct].self)
	}

	/// The API request for getting the user body profile data from the Virtusize server
	///
	/// - Returns: the user body profile data in the type of `VirtusizeUserBodyProfile`
	internal static func getUserBodyProfileAsync() -> APIResult<VirtusizeUserBodyProfile> {
		guard let request = APIRequest.getUserBodyProfile() else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: VirtusizeUserBodyProfile.self)
	}

	/// The API request for retrieving the recommended size based on the user body profile
	///
	/// - Parameters:
	///   - productTypes: A list of product types
	///   - storeProduct: The store product data
	///   - userBodyProfile: the user body profile data
	/// - Returns: the user body profile recommended size in the type of `BodyProfileRecommendedSize`
	internal static func getBodyProfileRecommendedSizeAsync(
		productTypes: [VirtusizeProductType],
		storeProduct: VirtusizeInternalProduct,
		userBodyProfile: VirtusizeUserBodyProfile
	) -> APIResult<BodyProfileRecommendedSize> {
		guard let request = APIRequest.getBodyProfileRecommendedSize(
				productTypes: productTypes,
				storeProduct: storeProduct,
				userBodyProfile: userBodyProfile) else {
			return .failure(nil)
		}
		return getAPIResultAsync(request: request, type: BodyProfileRecommendedSize.self)
	}

	/// The API request for getting i18 localization texts
	///
	/// - Parameters:
	///   - onSuccess: A callback to be called when the request to get i18n texts is successful
	///   - onError: A callback to pass `VirtusizeError` back when the request is unsuccessful
	internal static func getI18nTextsAsync() -> APIResult<VirtusizeI18nLocalization> {
		guard let virtusizeParams = Virtusize.params,
			let request = APIRequest.getI18n(
				langCode: virtusizeParams.language.rawValue
			) else {
			return .failure(nil)
		}

		let apiResponse = VirtusizeAPIService.performAsync(request)

		guard apiResponse?.virtusizeError == nil,
			let data = apiResponse?.data else {
			return .failure(apiResponse?.virtusizeError)
		}

		return .success(Deserializer.i18n(data: data))
	}

}
