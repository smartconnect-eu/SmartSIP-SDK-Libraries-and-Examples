//
//  SmartSipDemoApp.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 12/01/2026.
//

import SwiftUI
import UIKit
import smartsip_sdk

final class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        SmartSipSDK.onTerminate()
    }
}

@main
struct SmartSipDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
