//
//  VirtusizeParams.swift
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

import VirtusizeCore

/// The class that wraps the parameters we can pass to the Virtusize web app
public class VirtusizeParams {
	/// The `VirtusizeRegion` that is used to set the region of the config url domains within the Virtusize web app
	internal let region: VirtusizeRegion
	/// The `VirtusizeLanguage` that sets the initial language the Virtusize web app will load in
	internal let language: VirtusizeLanguage
	/// The languages that the user can switch to using the Language Selector
	private let allowedLanguages: [VirtusizeLanguage]
	// swiftlint:disable:next line_length
	/// The Boolean value to determine whether the Virtusize web app will fetch SGI and use SGI flow for users to add user generated items to their wardrobe
	private let showSGI: Bool
	/// The info categories that will be displayed in the Product Details tab
	private let detailsPanelCards: [VirtusizeInfoCategory]
    /// The Boolean value to determine whether the Virtusize web app will display the SNS buttons
    internal let showSNSButtons: Bool
	/// The branch name of testing environment. When specified, overrides the default endpoint of the Virtusize web app.
	internal let branch: String?
    /// The Boolean value to determine whether to show or hide the privacy policy
    internal let showPrivacyPolicy: Bool
    
	/// Initializes the VirtusizeParams class
	init(
		region: VirtusizeRegion,
		language: VirtusizeLanguage,
		allowedLanguages: [VirtusizeLanguage],
		showSGI: Bool,
		detailsPanelCards: [VirtusizeInfoCategory],
		showSNSButtons: Bool,
		branch: String?,
        showPrivacyPolicy: Bool
	) {
		self.region = region
		self.language = language
		self.allowedLanguages = allowedLanguages
		self.showSGI = showSGI
		self.detailsPanelCards = detailsPanelCards
        self.showSNSButtons = showSNSButtons
		self.branch = branch
        self.showPrivacyPolicy = showPrivacyPolicy
	}

	/// Gets the script in JavaScript to be called to pass params to the Virtusize web app
	///
	/// - Parameters:
	///   - externalProductId:The external product ID provided by the client.
	///   - userSessionResponse: The user session API response
	/// - Returns: A string value of the script in JavaScript
	func getVsParamsFromSDKScript(
		externalProductId: String?,
		userSessionResponse: String = ""
	) -> String {
		var paramsScript = "vsParamsFromSDK("
		guard let apiKey = Virtusize.APIKey else {
			fatalError("Please set Virtusize.APIKey")
		}
		guard let externalProductId = externalProductId else {
			fatalError("The external product ID is invalid")
		}
		paramsScript += "{\(ParamKey.API): '\(apiKey)', "
		paramsScript += "\(ParamKey.browserID): '\(UserDefaultsHelper.current.identifier)', "
		paramsScript += "\(ParamKey.sessionData): \(userSessionResponse), "
		paramsScript += "\(ParamKey.externalProductID): '\(externalProductId)', "
		paramsScript += "\(ParamKey.showSGI): \(showSGI), "
		paramsScript += "\(ParamKey.allowedLanguages): \(getAllowedLanguagesScript(allowedLanguages)), "
		paramsScript += "\(ParamKey.detailsPanelCards): \(detailsPanelCards.map { category in category.rawValue }), "
		paramsScript += "\(ParamKey.language): '\(language.rawValue)', "
		paramsScript += "\(ParamKey.region): '\(region.rawValue)', "
		paramsScript += "\(ParamKey.environment): '\(Virtusize.environment.isProdEnv ? "production" : "staging")'})"
		return paramsScript
	}

	/// Gets the script specific for allowedLanguages
	///
	/// - Parameter allowedLanguages: A list of `VirtusizeLanguage`
	/// - Returns: A string value of the script in JavaScript
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
		static let browserID = "bid"
		static let sessionData = "sessionData"
		static let region = "region"
		static let environment = "env"
		static let externalProductID = "externalProductId"
		static let externalUserID = "externalUserId"
		static let language = "language"
		static let showSGI = "showSGI"
		static let allowedLanguages = "allowedLanguages"
		static let detailsPanelCards = "detailsPanelCards"
	}
}
