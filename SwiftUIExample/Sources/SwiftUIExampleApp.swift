//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by Kuei Jung Hu on 2024/09/01.
//

import SwiftUI

@main
struct SwiftUIExampleApp {
    static func main() {
        if #available(iOS 14.0, *) {
            SwiftUIExampleView.main()
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct SwiftUIExampleView: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
