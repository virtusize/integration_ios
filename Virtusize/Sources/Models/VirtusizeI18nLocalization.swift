//
//  VirtusizeI18nLocalization.swift
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

/// The class that wraps the localization texts from the i18n endpoint
public class VirtusizeI18nLocalization {
	var defaultAccessoryText: String?
	var hasProductAccessoryTopText: String?
	var hasProductAccessoryBottomText: String?
	var oneSizeCloseTopText: String?
	var oneSizeSmallerTopText: String?
	var oneSizeLargerTopText: String?
	var oneSizeCloseBottomText: String?
	var oneSizeSmallerBottomText: String?
	var oneSizeLargerBottomText: String?
	var oneSizeWillFitResultText: String?
	var sizeComparisonMultiSizeText: String?
	var willFitResultText: String?
    var willNotFitResultText: String?
	var bodyDataEmptyText: String?

	/// Initializes the VirtusizeI18nLocalization structure
	init() {
		self.defaultAccessoryText = nil
		self.hasProductAccessoryTopText = nil
		self.hasProductAccessoryBottomText = nil
		self.oneSizeCloseTopText = nil
		self.oneSizeSmallerTopText = nil
		self.oneSizeLargerTopText = nil
		self.oneSizeCloseBottomText = nil
		self.oneSizeSmallerBottomText = nil
		self.oneSizeLargerBottomText = nil
		self.oneSizeWillFitResultText = nil
		self.sizeComparisonMultiSizeText = nil
		self.willFitResultText = nil
        self.willNotFitResultText = nil
		self.bodyDataEmptyText = nil
	}

	enum TrimType: String {
		case ONELINE = ""
		case MULTIPLELINES = "<br>"
	}

	/// Gets the default text where the recommendation is not available
	internal func getBodyDataEmptyText() -> String {
        return bodyDataEmptyText ?? Localization.shared.localize("inpage_body_data_empty_text")
	}

	/// Gets the default text for an accessory
	internal func getDefaultAccessoryText() -> String {
		return "\(defaultAccessoryText ?? Localization.shared.localize("inpage_default_accessory_text"))"
	}

	/// Gets the text for an accessory where the recommendation for product comparison is provided
	internal func getHasProductAccessoryText() -> String {
		let hasProductAccessoryTopText = self.hasProductAccessoryTopText ??
			Localization.shared.localize("inpage_has_product_top_text")
		let hasProductAccessoryBottomText = self.hasProductAccessoryBottomText ??
			Localization.shared.localize("inpage_has_product_bottom_text")
		return "\(hasProductAccessoryTopText) %{boldStart}\(hasProductAccessoryBottomText)%{boldEnd}"
	}

	/// Gets the product comparison text for a one-size product
	internal func getOneSizeProductComparisonText(
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize
	) -> String {
		if sizeComparisonRecommendedSize.bestFitScore > 84 {
			let oneSizeCloseTopText = self.oneSizeCloseTopText ??
				Localization.shared.localize("inpage_one_size_close_top_text")
			let oneSizeCloseBottomText = self.oneSizeCloseBottomText ??
				Localization.shared.localize("inpage_one_size_close_bottom_text")
			return "\(oneSizeCloseTopText) %{boldStart}\(oneSizeCloseBottomText)%{boldEnd}"
		} else if sizeComparisonRecommendedSize.isStoreProductSmaller == true {
			let oneSizeSmallerTopText = self.oneSizeSmallerTopText ??
				Localization.shared.localize("inpage_one_size_smaller_top_text")
			let oneSizeSmallerBottomText = self.oneSizeSmallerBottomText ??
				Localization.shared.localize("inpage_one_size_smaller_bottom_text")
			return "\(oneSizeSmallerTopText) %{boldStart}\(oneSizeSmallerBottomText)%{boldEnd}"
		}
		let oneSizeLargerTopText = self.oneSizeLargerTopText ??
			Localization.shared.localize("inpage_one_size_larger_top_text")
		let oneSizeLargerBottomText = self.oneSizeLargerBottomText ??
			Localization.shared.localize("inpage_one_size_larger_bottom_text")
		return "\(oneSizeLargerTopText) %{boldStart}\(oneSizeLargerBottomText)%{boldEnd}"
	}

	/// Gets the product comparison text for a multi-size product
	internal func getMultiSizeProductionComparisonText(_ sizeComparisonRecommendedSizeName: String) -> String {
		let sizeComparisonMultiSizeText = self.sizeComparisonMultiSizeText ??
			Localization.shared.localize("inpage_multi_size_comparison_text")
		return "\(sizeComparisonMultiSizeText) %{boldStart}\(sizeComparisonRecommendedSizeName)%{boldEnd}"
	}

	/// Gets the recommendation text for an one-size product based on a user body profile
	internal func getOneSizeBodyProfileText() -> String {
		return oneSizeWillFitResultText ?? Localization.shared.localize("inpage_one_size_will_fit_result_text")
	}

	/// Gets the recommendation text for a multi-size product based on a user body profile
	internal func getMultiSizeBodyProfileText(_ bodyProfileRecommendedSizeName: String) -> String {
		let willFitResultText = self.willFitResultText ?? Localization.shared.localize("inpage_will_fit_result")
		return "\(willFitResultText) %{boldStart}\(bodyProfileRecommendedSizeName)%{boldEnd}"
	}
}
