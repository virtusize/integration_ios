//
//  AoyamaParams.swift
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

import Foundation

public struct AoyamaParams {
    private let region: AoyamaRegion
    private let env: AoyamaEnvironment
    private let language: AoyamaLanguage
    private let allowedLanguages: [AoyamaLanguage]
    private let customTexts: String?
    private let storeProductId: Int?
    private let bid: String
    private let storeId: Int?
    private let externalUserId: String?
    private let showSGI: Bool
    private let detailsPanelCards: [AoyamaInfoCategory]

    init(region: AoyamaRegion = AoyamaRegion.COM,
         env: AoyamaEnvironment = AoyamaEnvironment.STAGE,
         language: AoyamaLanguage = AoyamaLanguage.ENGLISH,
         allowedLanguages: [AoyamaLanguage] = AoyamaLanguage.allCases,
         storeProductId: Int,
         storeId: Int,
         showSGI: Bool = true,
         detailsPanelCards: [AoyamaInfoCategory] = AoyamaInfoCategory.allCases) {
        self.region = region
        self.env = env
        self.language = language
        self.allowedLanguages = allowedLanguages
        self.customTexts = nil
        self.storeProductId = nil
        self.bid = BrowserID.current.identifier
        self.storeId = nil
        self.externalUserId = Virtusize.userID
        self.showSGI = showSGI
        self.detailsPanelCards = detailsPanelCards
    }
}
