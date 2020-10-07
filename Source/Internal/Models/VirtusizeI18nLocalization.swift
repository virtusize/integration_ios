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
internal class VirtusizeI18nLocalization {
    var defaultAccessoryText: String?
    var hasProductAccessoryTopText: String?
    var hasProductAccessoryBottomText: String?
    var oneSizeCloseTopText: String?
    var oneSizeSmallerTopText: String?
    var oneSizeLargerTopText: String?
    var oneSizeCloseBottomText: String?
    var oneSizeSmallerBottomText: String?
    var oneSizeLargerBottomText: String?
    var bodyProfileOneSizeText: String?
    var sizeComparisonMultiSizeText: String?
    var bodyProfileMultiSizeText: String?
    var noDataText: String?

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
        self.bodyProfileOneSizeText = nil
        self.sizeComparisonMultiSizeText = nil
        self.bodyProfileMultiSizeText = nil
        self.noDataText = nil
    }

    enum TrimType: String {
        case ONELINE = ""
        case MULTIPLELINES = "<br>"
    }

	// TODO: add comment
    internal func getHasProductAccessoryText() -> String? {
        guard let hasProductAccessoryTopText = hasProductAccessoryTopText,
              let hasProductAccessoryBottomText = hasProductAccessoryBottomText else {
            return nil
        }
        return "\(hasProductAccessoryTopText) %{boldStart}\(hasProductAccessoryBottomText)%{boldEnd}"
    }

	internal func getSizeComparisonOneSizeText(
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize
	) -> String? {
        if sizeComparisonRecommendedSize.bestFitScore > 84 {
            guard let oneSizeCloseTopText = oneSizeCloseTopText,
                  let oneSizeCloseBottomText = oneSizeCloseBottomText else {
                return nil
            }
            return "\(oneSizeCloseTopText) %{boldStart}\(oneSizeCloseBottomText)%{boldEnd}"
        } else if sizeComparisonRecommendedSize.isStoreProductSmaller == true {
            guard let oneSizeSmallerTopText = oneSizeSmallerTopText,
                  let oneSizeSmallerBottomText = oneSizeSmallerBottomText else {
                return nil
            }
            return "\(oneSizeSmallerTopText) %{boldStart}\(oneSizeSmallerBottomText)%{boldEnd}"
        }
        guard let oneSizeLargerTopText = oneSizeLargerTopText,
              let oneSizeLargerBottomText = oneSizeLargerBottomText else {
            return nil
        }
        return "\(oneSizeLargerTopText) %{boldStart}\(oneSizeLargerBottomText)%{boldEnd}"
    }

    internal func getSizeComparisonMultiSizeText(_ sizeComparisonRecommendedSizeName: String) -> String? {
        guard let sizeComparisonMultiSizeText = sizeComparisonMultiSizeText else {
            return nil
        }
        return "\(sizeComparisonMultiSizeText) %{boldStart}\(sizeComparisonRecommendedSizeName)%{boldEnd}"
    }

    internal func getBodyProfileMultiSizeText(_ bodyProfileRecommendedSizeName: String) -> String? {
        guard let bodyProfileMultiSizeText = bodyProfileMultiSizeText else {
            return nil
        }
        return "\(bodyProfileMultiSizeText) %{boldStart}\(bodyProfileRecommendedSizeName)%{boldEnd}"
    }
}
