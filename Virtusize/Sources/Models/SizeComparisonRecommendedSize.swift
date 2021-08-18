//
//  SizeComparisonRecommendedSize.swift
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

// This structure wraps the product comparison recommended size info
public struct SizeComparisonRecommendedSize {
	/// The best fit score for product comparison
	var bestFitScore: Double
	/// The best store product size for the user
	var bestStoreProductSize: VirtusizeProductSize?
	/// The best fit user product out of all the comparable user products
	public var bestUserProduct: VirtusizeServerProduct?
	/// The boolean value for whether the best fit user product is smaller than the store product
	var isStoreProductSmaller: Bool?

	init() {
		bestFitScore = 0.0
		bestStoreProductSize = nil
		bestUserProduct = nil
		isStoreProductSmaller = nil
	}

	internal func isValid() -> Bool {
		return bestFitScore != 0.0 || bestStoreProductSize != nil || bestUserProduct != nil || isStoreProductSmaller != nil
	}
}
