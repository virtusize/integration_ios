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
	let userProductImage: Observable<VirtusizeProductImage?> = Observable(nil)
	let storeProductImage: Observable<VirtusizeProductImage?> = Observable(nil)

	private var currentBestFitUserProduct: VirtusizeInternalProduct?
	private var currentStoreProduct: VirtusizeProduct?

	func loadUserProductImage(bestFitUserProduct: VirtusizeInternalProduct) {
		if currentBestFitUserProduct != nil && currentBestFitUserProduct!.id == bestFitUserProduct.id {
			self.userProductImage.value = self.userProductImage.value
			return
		}
		currentBestFitUserProduct = bestFitUserProduct
		DispatchQueue.global().async {
			self.userProductImage.value = nil
			let cloudinaryImageURL = self.getCloudinaryImageUrl(bestFitUserProduct.cloudinaryPublicId)
			let loadImageResponse = VirtusizeAPIService.loadImageAsync(url: cloudinaryImageURL)
			if let userProductImage = loadImageResponse.success {
				self.userProductImage.value = VirtusizeProductImage(
					image: userProductImage,
					source: .cloudinary
				)
			} else {
				let productTypeImage = self.getProductTypeImage(
					productType: bestFitUserProduct.productType,
					style: bestFitUserProduct.storeProductMeta?.additionalInfo?.style
				)
				self.userProductImage.value = VirtusizeProductImage(
					image: productTypeImage,
					source: .local
				)
			}
		}
	}

	func loadStoreProductImage() {
		guard currentStoreProduct?.externalId != Virtusize.internalProduct?.externalId ||
			  self.storeProductImage.value == nil
		else {
			self.storeProductImage.value = self.storeProductImage.value
			return
		}
		currentStoreProduct = Virtusize.internalProduct
		DispatchQueue.global().async {
			if let clientProductImage = VirtusizeAPIService.loadImageAsync(url: Virtusize.product?.imageURL).success {
				self.storeProductImage.value = VirtusizeProductImage(
					image: clientProductImage,
					source: .client
				)
			} else {
				let cloudinaryImageURL = self.getCloudinaryImageUrl(VirtusizeRepository.shared.storeProduct!.cloudinaryPublicId)
				if let storeProductImage = VirtusizeAPIService.loadImageAsync(url: cloudinaryImageURL).success {
					self.storeProductImage.value = VirtusizeProductImage(
						image: storeProductImage,
						source: .cloudinary
					)
				} else {
					let productTypeImage = self.getProductTypeImage(
						productType: VirtusizeRepository.shared.storeProduct!.productType,
						style: VirtusizeRepository.shared.storeProduct!.storeProductMeta?.additionalInfo?.style
					)
					self.storeProductImage.value = VirtusizeProductImage(
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
