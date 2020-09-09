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
    var defaultText: String?
    var defaultAccessoryText: String?
    var sizingItemBrandLargeText: String?
    var sizingItemBrandTrueText: String?
    var sizingItemBrandSmallText: String?
    var sizingMostBrandsLargeText: String?
    var sizingMostBrandsTrueText: String?
    var sizingMostBrandsSmallText: String?
    var fitLooseText: String?
    var fitRegularText: String?
    var fitTightText: String?

    /// Initializes the VirtusizeI18nLocalization structure
    init() {
        self.defaultText = nil
        self.defaultAccessoryText = nil
        self.sizingItemBrandLargeText = nil
        self.sizingItemBrandTrueText = nil
        self.sizingItemBrandSmallText = nil
        self.sizingMostBrandsLargeText = nil
        self.sizingMostBrandsTrueText = nil
        self.sizingMostBrandsSmallText = nil
        self.fitLooseText = nil
        self.fitRegularText = nil
        self.fitTightText = nil
    }

    /// Gets the sizing text based on the brand sizing info
    func getSizingText(brandSizing: VirtusizeBrandSizing) -> String? {
        if brandSizing.itemBrand {
            switch brandSizing.compare {
            case "large":
                return self.sizingItemBrandLargeText
            case "true":
                return self.sizingItemBrandTrueText
            case "small":
                return self.sizingItemBrandSmallText
            default:
                return nil
            }
        } else {
            switch brandSizing.compare {
            case "large":
                return self.sizingMostBrandsLargeText
            case "true":
                return self.sizingMostBrandsTrueText
            case "small":
                return self.sizingMostBrandsSmallText
            default:
                return nil
            }
        }
    }

    /// Gets the general fit text based on the general fit key
    func getFitText(generalFitKey: String) -> String? {
        switch generalFitKey {
        case "loose":
            return self.fitLooseText
        case "regular":
            return self.fitRegularText
        case "tight":
            return self.fitTightText
        default:
            return nil
        }
    }

    enum TrimType: String {
        case ONELINE = ""
        case MULTIPLELINES = "<br>"
    }
}
