//
//  VirtusizeInPageStandardViewModel.swift
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

internal final class VirtusizeInPageStandardViewModel {
	let userProductImageObservable: Observable<VirtusizeProductImage?> = Observable(nil)
	let storeProductImageObservable: Observable<VirtusizeProductImage?> = Observable(nil)

	private var currentBestFitUserProduct: VirtusizeStoreProduct?
	private var currentStoreProductId: String?
	private let dispatchQueue = DispatchQueue(label: "com.virtusize.inpage-image-queue")

	func loadUserProductImage(bestFitUserProduct: VirtusizeStoreProduct) {
		if currentBestFitUserProduct != nil && currentBestFitUserProduct!.id == bestFitUserProduct.id {
			self.userProductImageObservable.value = self.userProductImageObservable.value
			return
		}
		currentBestFitUserProduct = bestFitUserProduct
		dispatchQueue.async {
			self.userProductImageObservable.value = nil
			let cloudinaryImageURL = self.getCloudinaryImageUrl(bestFitUserProduct.cloudinaryPublicId)
			let loadImageResponse = VirtusizeAPIService.loadImageAsync(url: cloudinaryImageURL)
			if let userProductImage = loadImageResponse.success {
				self.userProductImageObservable.value = VirtusizeProductImage(
					image: userProductImage,
					source: .cloudinary
				)
			} else {
				let productTypeImage = self.getProductTypeImage(
					productType: bestFitUserProduct.productType,
					style: bestFitUserProduct.storeProductMeta?.additionalInfo?.style
				)
				self.userProductImageObservable.value = VirtusizeProductImage(
					image: productTypeImage,
					source: .local
				)
			}
		}
	}

	func loadStoreProductImage(storeProductId: String?) {
		guard currentStoreProductId != storeProductId || self.storeProductImageObservable.value == nil
		else {
			self.storeProductImageObservable.value = self.storeProductImageObservable.value
			return
		}
		currentStoreProductId = storeProductId

		dispatchQueue.async {
			if let clientProductImage = VirtusizeAPIService.loadImageAsync(url: Virtusize.product?.imageURL).success {
				self.storeProductImageObservable.value = VirtusizeProductImage(
					image: clientProductImage,
					source: .client
				)
			} else {
				let cloudinaryImageURL = self.getCloudinaryImageUrl(VirtusizeRepository.shared.currentProduct!.cloudinaryPublicId)
				if let storeProductImage = VirtusizeAPIService.loadImageAsync(url: cloudinaryImageURL).success {
					self.storeProductImageObservable.value = VirtusizeProductImage(
						image: storeProductImage,
						source: .cloudinary
					)
				} else {
					let productTypeImage = self.getProductTypeImage(
						productType: VirtusizeRepository.shared.currentProduct!.productType,
						style: VirtusizeRepository.shared.currentProduct!.storeProductMeta?.additionalInfo?.style
					)
					self.storeProductImageObservable.value = VirtusizeProductImage(
						image: productTypeImage,
						source: .local
					)
				}
			}
		}
	}

	private func getCloudinaryImageUrl(_ cloudinaryPublicId: String?) -> URL? {
		guard let cloudinaryPublicId = cloudinaryPublicId else {
			return nil
		}
		return URL(string:
			"https://res.cloudinary.com/virtusize/image/upload/w_36,h_36/q_auto,f_auto,dpr_auto/\(cloudinaryPublicId).jpg"
		)
	}

	private func getProductTypeImage(productType: Int, style: String?) -> UIImage? {
		return VirtusizeAssets.getProductPlaceholderImage(
			productType: productType,
			style: style
		)?.withPadding(inset: 8)?.withRenderingMode(.alwaysTemplate)
	}
}
