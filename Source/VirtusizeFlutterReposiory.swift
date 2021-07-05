//
//  VirtusizeFlutterRepository.swift
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

public class VirtusizeFlutterRepository: NSObject {
	public static let shared: VirtusizeFlutterRepository = {
		let instance = VirtusizeFlutterRepository()
		return instance
	}()
	
	public func getProductDataCheck(product: VirtusizeProduct) -> (VirtusizeProduct?, String?) {
		let productResponse = VirtusizeAPIService.productCheckAsync(product: product)
		var isValidProduct: Bool = false
		sendEventsAndProductImage(productResponse: productResponse) { isValid in
			isValidProduct = isValid
		}
		return (isValidProduct ? productResponse.success : nil, isValidProduct ? productResponse.string : nil)
	}

	private func sendEventsAndProductImage(
		productResponse: APIResult<VirtusizeProduct>,
		onValidProduct: (Bool) -> Void
	) {
		guard let product = productResponse.success else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": productResponse.string ?? VirtusizeError.unknownError.debugDescription]
			)
			onValidProduct(false)
			return
		}

		// Send the API event where the user saw the product
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawProduct),
			withContext: product.jsonObject
		)

		guard product.productCheckData?.productDataId != nil else {
			NotificationCenter.default.post(
				name: Virtusize.productDataCheckDidFail,
				object: Virtusize.self,
				userInfo: ["message": product.dictionary]
			)
			onValidProduct(false)
			return
		}

		if let sendImageToBackend = product.productCheckData?.fetchMetaData,
		   sendImageToBackend,
		   product.imageURL != nil,
		   let storeId = product.productCheckData?.storeId {
			VirtusizeAPIService.sendProductImage(of: product, forStore: storeId)
		}

		// Send the API event where the user saw the widget button
		VirtusizeAPIService.sendEvent(
			VirtusizeEvent(name: .userSawWidgetButton),
			withContext: product.jsonObject
		)

		NotificationCenter.default.post(
			name: Virtusize.productDataCheckDidSucceed,
			object: Virtusize.self,
			userInfo: ["message": product.dictionary]
		)

		onValidProduct(true)
	}

	public func getStoreProduct(productId: Int) -> VirtusizeStoreProduct? {
		let response = VirtusizeAPIService.getStoreProductInfoAsync(productId: productId)
		return response.isSuccessful ? response.success : nil
	}

	public func getProductTypes() -> [VirtusizeProductType]? {
		let response = VirtusizeAPIService.getProductTypesAsync()
		return response.isSuccessful ? response.success : nil
	}

	public func getI18nLocalization() -> VirtusizeI18nLocalization? {
		let response = VirtusizeAPIService.getI18nTextsAsync()
		return response.isSuccessful ? response.success : nil
	}
}
