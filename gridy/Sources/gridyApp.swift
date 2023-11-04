//
//  gridyApp.swift
//  gridy
//
//  Created by 제나 on 2023/09/21.
//

import SwiftUI
import Firebase
import ComposableArchitecture

@main
struct GridyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
//                ContentView()
                let viewModel = AutoCompleteViewModel()
                ListContentView(autoCompleteViewModel: AutoCompleteViewModel())
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }
}
