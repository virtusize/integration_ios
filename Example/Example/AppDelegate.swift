//
//  AppDelegate.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

import UIKit
import Virtusize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Virtusize.APIKey is required
        Virtusize.APIKey = "15cc36e1d7dad62b8e11722ce1a245cb6c5e6692"
        // For using the Order API, Virtusize.userID is required
        Virtusize.userID = "123"
        // By default, the Virtusize environment will be set to .global
        Virtusize.environment = .staging
        Virtusize.params = VirtusizeParamsBuilder()
            // By default, the initial language will be set based on the Virtusize environment
            .setLanguage(.ENGLISH)
             // By default, ShowSGI is false
            .setShowSGI(true)
             // By default, Virtusize allows all the possible languages including English, Japanese and Korean
            .setAllowedLanguages([VirtusizeLanguage.ENGLISH, VirtusizeLanguage.JAPANESE])
             // By default, Virtusize displays all the possible info categories in the Product Details tab,
             // including "modelInfo", "generalFit", "brandSizing" and "material".
            .setDetailsPanelCards([VirtusizeInfoCategory.BRANDSIZING, VirtusizeInfoCategory.GENERALFIT])
            .build()
		return true
	}
}
