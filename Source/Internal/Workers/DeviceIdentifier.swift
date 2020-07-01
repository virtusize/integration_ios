//
//  DeviceIdentifier.swift
//
//  Copyright (c) 2018-20 Virtusize AB
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

/// This class is used to get a unique identifier to each device or each app from the same development team
internal class DeviceIdentifier {

    /// Gets the ASIdentifierManager class without importing AdSupport in the SDK
    private static var advertisingIdentifierManager: ASIdentifierManager? = {
        let selector = #selector(ASIdentifierManager.sharedManager)

        guard let NSClass = NSClassFromString("ASIdentifierManager"),
              let identifierManagerClass = NSClass as AnyObject as? NSObjectProtocol else {
            return nil
        }

        guard identifierManagerClass.responds(to: selector) else {
            return nil
        }

        let sharedManager = identifierManagerClass.perform(selector).takeUnretainedValue()

        return unsafeBitCast(sharedManager, to: ASIdentifierManager.self)
    }()

    /// Gets a unique device identifier
    ///
    /// - Note: For IDFA to be available, a developer has to link in `AdSupport.framework`
    ///
    /// - Returns: `advertisingIdentifier` if it's available.
    /// Otherwise, `identifierForVendor`, that is unique for the apps from the same development team
    static func getUniqueDeviceId() -> String? {
        if advertisingIdentifierManager?.isAdvertisingTrackingEnabled ?? false,
            let idfa = advertisingIdentifierManager?.advertisingIdentifier?.uuidString,
            idfa != "00000000-0000-0000-0000-000000000000" {
            return idfa
        }
        return UIDevice.current.identifierForVendor?.uuidString
    }
}
