//
//  Deserializer.swift
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

import Foundation
import VirtusizeCore

/// A structure that helps to deserialize the models specific to the Virtusize API
internal struct Deserializer {

	/// Gets `VirtusizeEvent` with the optional data to be sent to the Virtusize server
	///
	/// - Parameter data: The optional data for the event
	/// - Throws: `VirtusizeError`
	/// - Returns: `VirtusizeEvent`
	static func event(data: Any?) throws -> VirtusizeEvent {
		let event: [String: Any]

		if let eventData = data as? [String: Any] {
			event = eventData
		} else if let data = data as? Data,
				  let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
				  let eventData = deserialized as? [String: Any] {
			event = eventData
		} else if let string = data as? String {
			guard let data = string.data(using: .utf8) else {
				throw VirtusizeError.encodingError
			}
			if let deserialized = try? JSONSerialization.jsonObject(with: data, options: []),
			   let eventData = deserialized as? [String: Any] {
				event = eventData
			} else {
				throw VirtusizeError.deserializationError
			}
		} else {
			throw VirtusizeError.deserializationError
		}

		guard let eventName: String = event["eventName"] as? String else {
			throw VirtusizeError.invalidPayload
		}

		return VirtusizeEvent(name: eventName, data: event)
	}

	/// Gets `VirtusizeI18nLocalization` from the data response from the i18n request
	///
	/// - Parameter data: The data for the localization texts
	/// - Returns: `VirtusizeI18nLocalization`
	static func i18n(data: Data?) -> VirtusizeI18nLocalization {
		guard let data = data,
			  let rootObject = try? JSONSerialization.jsonObject(with: data, options: []),
			  let root = rootObject as? JSONObject else {
			return VirtusizeI18nLocalization()
		}
		return i18n(json: root)
	}

	/// Decodes `VirtusizeI18nLocalization` from the JSON data
	///
	/// - Parameter json: The JSON data for the localization texts
	/// - Returns: `VirtusizeI18nLocalization`
	static func i18n(json: JSONObject?) -> VirtusizeI18nLocalization {
		let i18nLocalization = VirtusizeI18nLocalization()
		guard let root = json,
			  let keysJSONObject = root["keys"] as? JSONObject,
			  let appsJSONObject = keysJSONObject["apps"] as? JSONObject,
			  let aoyamaJSONObject = appsJSONObject["aoyama"] as? JSONObject else {
			return i18nLocalization
		}

		let inpageJSONObject = aoyamaJSONObject["inpage"] as? JSONObject
		let oneSizeJSONObject = inpageJSONObject?["oneSize"] as? JSONObject
		let multiSizeJSONObject = inpageJSONObject?["multiSize"] as? JSONObject
		let accessoryJSONObject = inpageJSONObject?["accessory"] as? JSONObject

		i18nLocalization.defaultAccessoryText = inpageJSONObject?["defaultAccessoryText"] as? String
		i18nLocalization.hasProductAccessoryTopText = accessoryJSONObject?["hasProductLead"] as? String
		i18nLocalization.hasProductAccessoryBottomText = accessoryJSONObject?["hasProduct"] as? String
		i18nLocalization.oneSizeCloseTopText = oneSizeJSONObject?["closeLead"] as? String
		i18nLocalization.oneSizeSmallerTopText = oneSizeJSONObject?["smallerLead"] as? String
		i18nLocalization.oneSizeLargerTopText = oneSizeJSONObject?["largerLead"] as? String
		i18nLocalization.oneSizeCloseBottomText = oneSizeJSONObject?["close"] as? String
		i18nLocalization.oneSizeSmallerBottomText = oneSizeJSONObject?["smaller"] as? String
		i18nLocalization.oneSizeLargerBottomText = oneSizeJSONObject?["larger"] as? String
		i18nLocalization.oneSizeWillFitResultText = inpageJSONObject?["oneSizeWillFitResult"] as? String
		i18nLocalization.sizeComparisonMultiSizeText = multiSizeJSONObject?["sizeComparison"] as? String
		i18nLocalization.willFitResultText = inpageJSONObject?["willFitResult"] as? String
		i18nLocalization.willNotFitResultText = inpageJSONObject?["willNotFitResult"] as? String
		i18nLocalization.bodyDataEmptyText = inpageJSONObject?["bodydataEmpty"] as? String

		return i18nLocalization
	}
}
