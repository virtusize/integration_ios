//
//  AoyamaParamsBuilder.swift
//
//  Copyright (c) 2020 Virtusize AB
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

public class AoyamaParamsBuilder {

    private var region: AoyamaRegion = AoyamaRegion.JAPAN
    private var env: AoyamaEnvironment = AoyamaEnvironment.PRODUCTION
    private var language: AoyamaLanguage = AoyamaLanguage.JAPANESE
    private var allowedLanguages: [AoyamaLanguage] = AoyamaLanguage.allCases
    private var virtusizeProduct: VirtusizeProduct?
    private var showSGI: Bool = false
    private var detailsPanelCards: [AoyamaInfoCategory] = AoyamaInfoCategory.allCases

    public init() {}

    public func setRegion(_ value: AoyamaRegion) -> AoyamaParamsBuilder {
        region = value
        return self
    }

    public func setEnvironment(_ value: AoyamaEnvironment) -> AoyamaParamsBuilder {
        env = value
        return self
    }

    public func setLanguage(_ value: AoyamaLanguage) -> AoyamaParamsBuilder {
        language = value
        return self
    }

    public func setAllowedLanguages(_ value: [AoyamaLanguage]) -> AoyamaParamsBuilder {
        allowedLanguages = value
        return self
    }

    public func setVirtusizeProduct(_ value: VirtusizeProduct) -> AoyamaParamsBuilder {
        virtusizeProduct = value
        return self
    }

    public func build() -> AoyamaParams {
        return AoyamaParams(
            region: region,
            env: env,
            language: language,
            allowedLanguages: allowedLanguages,
            virtusizeProduct: virtusizeProduct,
            showSGI: showSGI,
            detailsPanelCards: detailsPanelCards
        )
    }
}
