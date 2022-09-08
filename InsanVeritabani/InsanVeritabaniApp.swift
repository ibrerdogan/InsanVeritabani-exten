//
//  InsanVeritabaniApp.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
@main
struct InsanVeritabaniApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            //ContentView()
            //ProfileView()
            LoginView()
            //CheckEksiNickName()
        }
    }
}
