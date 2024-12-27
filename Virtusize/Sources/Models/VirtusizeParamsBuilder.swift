//
//  VirtusizeParamsBuilder.swift
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

/// The builder patten to help initialize the `VirtusizeParams` object
public class VirtusizeParamsBuilder {
	private var region: VirtusizeRegion = VirtusizeRegion.JAPAN
	private var language: VirtusizeLanguage?
	private var allowedLanguages: [VirtusizeLanguage] = VirtusizeLanguage.allCases
	private var virtusizeProduct: VirtusizeProduct?
	private var showSGI: Bool = false
	private var detailsPanelCards: [VirtusizeInfoCategory] = VirtusizeInfoCategory.allCases
    private var showSNSButtons: Bool = false

	public init() {}

	public func setLanguage(_ value: VirtusizeLanguage) -> VirtusizeParamsBuilder {
		language = value
		return self
	}

	public func setAllowedLanguages(_ value: [VirtusizeLanguage]) -> VirtusizeParamsBuilder {
		allowedLanguages = value
		return self
	}

	public func setShowSGI(_ value: Bool) -> VirtusizeParamsBuilder {
		showSGI = value
		return self
	}

	public func setDetailsPanelCards(_ value: [VirtusizeInfoCategory]) -> VirtusizeParamsBuilder {
		detailsPanelCards = value
		return self
	}

    public func setShowSNSButtons(_ value: Bool) -> VirtusizeParamsBuilder {
        showSNSButtons = value
        return self
    }

	public func build() -> VirtusizeParams {
		/// Assigns the region value to a default one corresponding the Virtusize environment
		region = Virtusize.environment.virtusizeRegion()
		return VirtusizeParams(
			region: region,
			language: language ?? region.defaultLanguage(),
			allowedLanguages: allowedLanguages,
			showSGI: showSGI,
			detailsPanelCards: detailsPanelCards,
            showSNSButtons: showSNSButtons
		)
	}
}
