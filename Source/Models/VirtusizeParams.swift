//
//  VirtusizeParams.swift
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

public class VirtusizeParams {
    internal let region: VirtusizeRegion
    private let language: VirtusizeLanguage
    private let allowedLanguages: [VirtusizeLanguage]
    private let showSGI: Bool
    private let detailsPanelCards: [VirtusizeInfoCategory]

    init(region: VirtusizeRegion,
         language: VirtusizeLanguage,
         allowedLanguages: [VirtusizeLanguage],
         showSGI: Bool,
         detailsPanelCards: [VirtusizeInfoCategory]) {
        self.region = region
        self.language = language
        self.allowedLanguages = allowedLanguages
        self.showSGI = showSGI
        self.detailsPanelCards = detailsPanelCards
    }

    func getVsParamsFromSDKScript() -> String {
        var paramsScript = "vsParamsFromSDK("
        guard let apiKey = Virtusize.APIKey else {
            fatalError("Please set Virtusize.APIKey")
        }
        guard let storeProductId = Virtusize.product?.externalId else {
            fatalError("product ID is invalid")
        }
        paramsScript += "{\(ParamKey.API): '\(apiKey)', "
        paramsScript += "\(ParamKey.storeProductID): '\(storeProductId)', "
        if let userId = Virtusize.userID {
            paramsScript += "\(ParamKey.externalUserID): '\(userId)', "
        }
        paramsScript += "\(ParamKey.showSGI): \(showSGI), "
        paramsScript += "\(ParamKey.allowedLanguages): \(getAllowedLanguagesScript(allowedLanguages)), "
        paramsScript += "\(ParamKey.detailsPanelCards): \(detailsPanelCards.map { category in category.rawValue }), "
        paramsScript += "\(ParamKey.language): '\(language.rawValue)', "
        paramsScript += "\(ParamKey.region): '\(region.rawValue)', "
        paramsScript += "\(ParamKey.environment): 'production'})"
        print(paramsScript)
        return paramsScript
    }

    private func getAllowedLanguagesScript(_ allowedLanguages: [VirtusizeLanguage]) -> String {
        var script = "["
        for index in 0...allowedLanguages.count-1 {
            script += "{ label : \"\(allowedLanguages[index].label)\", value : \"\(allowedLanguages[index].rawValue)\"}"
            if index != allowedLanguages.count-1 {
                script += ", "
            }
        }
        script += "]"
        return script
    }

    enum ParamKey {
        static let API = "apiKey"
        static let region = "region"
        static let environment = "env"
        static let storeProductID = "externalProductId"
        static let externalUserID = "externalUserId"
        static let language = "language"
        static let showSGI = "showSGI"
        static let allowedLanguages = "allowedLanguages"
        static let detailsPanelCards = "detailsPanelCards"
    }

}
