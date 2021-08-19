//
//  AppDelegate.swift
//  SwiftUIExample
//
//  Copyright (c) 2021-present Virtusize KK
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
import SwiftUI
import Virtusize

// swiftlint:disable line_length
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		// Virtusize.APIKey is required
		Virtusize.APIKey = "15cc36e1d7dad62b8e11722ce1a245cb6c5e6692"
		// For using the Order API, Virtusize.userID is required
		Virtusize.userID = "123"
		// By default, the Virtusize environment will be set to .global
		Virtusize.environment = .staging
		Virtusize.params = VirtusizeParamsBuilder()
			// By default, the initial language will be set based on the Virtusize environment
			.setLanguage(.JAPANESE)
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

	// MARK: UISceneSession Lifecycle

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}
