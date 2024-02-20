//
//  VirtusizeEnvironment.swift
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

/// This enum contains all available Virtusize environments
public enum VirtusizeEnvironment: String, CaseIterable {
	case TESTING="testing.virtusize.jp"
	case STAGING="staging.virtusize.com"
	case GLOBAL="api.virtusize.com"
	case JAPAN="api.virtusize.jp"
	case KOREA="api.virtusize.kr"

	var isProdEnv: Bool {
		return self == .GLOBAL || self == .JAPAN || self == .KOREA
	}

	/// Gets the services URL for the `productDataCheck` and `getSize` requests
	internal func servicesUrl() -> String {
		// swiftlint:disable switch_case_alignment
		switch self {
			case .TESTING:
				return "services.virtusize.jp"
			case .STAGING:
				return "services.virtusize.com"
			case .GLOBAL:
				return "services.virtusize.com"
			case .JAPAN:
				return "services.virtusize.jp"
			case .KOREA:
				return "services.virtusize.kr"
		}
	}
    
    /// Gets the services URL for the ``getSize` requests
    internal func getSizeUrl() -> String {
        // swiftlint:disable switch_case_alignment
        switch self {
            case .TESTING:
                return "size-recommendation.virtusize.jp"
            case .STAGING:
                return "size-recommendation.virtusize.com"
            case .GLOBAL:
                return "size-recommendation.virtusize.com"
            case .JAPAN:
                return "size-recommendation.virtusize.jp"
            case .KOREA:
                return "size-recommendation.virtusize.kr"
        }
    }

	/// Gets the URL for the `i18n` request
	internal func i18nUrl() -> String {
		return "i18n.virtusize.com"
	}

	/// Gets the static API URL for the `VirtusizeWebView` request
	internal func virtusizeStaticApiUrl() -> String {
		switch self {
			case .STAGING, .GLOBAL:
				return "static.api.virtusize.com"
			case .TESTING, .JAPAN:
				return "static.api.virtusize.jp"
			case .KOREA:
				return "static.api.virtusize.kr"
		}
	}

	/// Gets the event API URL corresponding to the Virtusize environment
	internal func eventApiUrl() -> String {
		switch self {
			case .TESTING:
				return "events.testing.virtusize.jp"
			case .STAGING:
				return "events.staging.virtusize.com"
			case .JAPAN:
				return "events.virtusize.jp"
			case .GLOBAL:
				return "events.virtusize.com"
			case .KOREA:
				return "events.virtusize.kr"
		}
	}

	/// Gets the `VirtusizeRegion` corresponding to the Virtusize environment
	internal func virtusizeRegion() -> VirtusizeRegion {
		switch self {
			case .STAGING, .GLOBAL:
				return VirtusizeRegion.COM
			case .TESTING, .JAPAN:
				return VirtusizeRegion.JAPAN
			case .KOREA:
				return VirtusizeRegion.KOREA
		}
	}
}
