//
//  RepositoryTests.swift
//  Virtusize
//
//  Copyright (c) 2025-present Virtusize KK
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

import Testing
@testable import Virtusize
@testable import VirtusizeCore

@Suite(.serialized)
struct I18nTests {
	init() {
		Virtusize.APIKey = TestFixtures.apiKey
		Virtusize.userID = "123"
		Virtusize.environment = .STAGING
	}

	@Test func no_specific_texts() async {
		let repo = VirtusizeRepository()
		let mockSession = MockURLSession()

		mockSession.mockResponse(
			endpoint: APIEndpoints.storeViewApiKey,
			data: TestFixtures.fullStoreInfoJsonResponse.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.i18n(langCode: "en"),
			data: TestFixtures.i18nEN.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.storeI18n(storeName: "virtusize"),
			data: Data())

		VirtusizeAPIService.session = mockSession

		let localization = await repo.fetchLocalization(language: VirtusizeLanguage.ENGLISH)
		#expect(localization?.willFitResultText == "Your recommended size is ")
	}

	@Test func handle_specific_texts_no_override() async {
		let repo = VirtusizeRepository()
		let mockSession = MockURLSession()

		mockSession.mockResponse(
			endpoint: APIEndpoints.storeViewApiKey,
			data: TestFixtures.fullStoreInfoJsonResponse.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.i18n(langCode: "en"),
			data: TestFixtures.i18nEN.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.storeI18n(storeName: "virtusize"),
			data: TestFixtures.storeI18n.data(using: .utf8))

		VirtusizeAPIService.session = mockSession

		let localization = await repo.fetchLocalization(language: VirtusizeLanguage.ENGLISH)
		#expect(localization?.willFitResultText == "Your recommended size is ")
	}

	@Test func handle_specific_texts_with_override() async {
		let repo = VirtusizeRepository()
		let mockSession = MockURLSession()

		mockSession.mockResponse(
			endpoint: APIEndpoints.storeViewApiKey,
			data: TestFixtures.fullStoreInfoJsonResponse.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.i18n(langCode: "ja"),
			data: TestFixtures.i18nEN.data(using: .utf8))
		mockSession.mockResponse(
			endpoint: APIEndpoints.storeI18n(storeName: "virtusize"),
			data: TestFixtures.storeI18n.data(using: .utf8))

		VirtusizeAPIService.session = mockSession

		let localization = await repo.fetchLocalization(language: VirtusizeLanguage.JAPANESE)
		#expect(localization?.willFitResultText == "あなたの体型に人気のサイズ")
	}
}
