//
//  FindBestFitHelper.swift
//
//  Copyright (c) 2020 Virtusize KK
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

// This class contains the functions that get the best fit result based on product comparison
internal class FindBestFitHelper {

	/// Finds the size of the best fit product by comparing user products with the store product
	///
	/// - Parameters:
	///   - userProducts: The list of user products
	///   - storeProduct: The store product
	///   - productTypes: The list of available product types
	static func findBestFitProductSize(
		userProducts: [VirtusizeServerProduct],
		storeProduct: VirtusizeServerProduct,
		productTypes: [VirtusizeProductType]
	) -> SizeComparisonRecommendedSize? {
		let storeProductType = productTypes.first(where: { $0.id == storeProduct.productType })
		let compatibleUserProducts = userProducts.filter {
			(storeProductType?.compatibleWith.contains($0.productType) ?? false)
		}
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		compatibleUserProducts.forEach({ userProduct in
			let userProductSize = userProduct.sizes[0]
			storeProduct.sizes.forEach({ storeProductSize in
				let storeProductFitInfo = getStoreProductFitInfo(
					userProductSize: userProductSize,
					storeProductSize: storeProductSize,
					storeProductTypeScoreWeights: storeProductType?.weights ?? [:]
				)
				if storeProductFitInfo.fitScore > sizeComparisonRecommendedSize.bestFitScore {
					sizeComparisonRecommendedSize.bestFitScore = storeProductFitInfo.fitScore
					sizeComparisonRecommendedSize.bestStoreProductSize = storeProductSize
					sizeComparisonRecommendedSize.bestUserProduct = userProduct
					sizeComparisonRecommendedSize.isStoreProductSmaller = storeProductFitInfo.isSmaller
				}
			})
		})
		return sizeComparisonRecommendedSize
	}

	/// Gets the product comparison fit info
	///
	/// - Parameters:
	///   - userProductSize: The size of a user product
	///   - storeProductSize: The size of a store product
	///   - storeProductTypeScoreWeights: The weights of the store product for calculation
	static func getStoreProductFitInfo(
		userProductSize: VirtusizeProductSize,
		storeProductSize: VirtusizeProductSize,
		storeProductTypeScoreWeights: [String: Double]
	) -> ProductComparisonFitInfo {
		var rawScore = 0.0
		var isSmaller: Bool?

		storeProductTypeScoreWeights.sorted { $0.1 > $1.1 }.forEach({ weight in
			let userProductSizeMeasurement = userProductSize.measurements
				.first(where: { $0.key == weight.key })?.value
			let storeProductSizeMeasurement = storeProductSize.measurements
				.first(where: { $0.key == weight.key })?.value
			if userProductSizeMeasurement != nil && storeProductSizeMeasurement != nil {
				rawScore += Double(
					abs(weight.value * Double(userProductSizeMeasurement! - storeProductSizeMeasurement!))
				)
				isSmaller = isSmaller ?? (userProductSizeMeasurement! - storeProductSizeMeasurement! > 0)
			}
		})

		let adjustScore = rawScore / 10.0
		let fitScore = max(100 - adjustScore, 20)

		return ProductComparisonFitInfo(fitScore: fitScore, isSmaller: isSmaller)
	}
}
