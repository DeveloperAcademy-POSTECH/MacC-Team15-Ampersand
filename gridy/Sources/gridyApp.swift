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
    
    @Environment(\.colorScheme) private var colorScheme
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    GeometryReader { _ in
                        ZStack {
                            colorScheme == .dark ? Color.black.opacity(0.2) : Color.white
                            Image(.gridBackground)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(Color.gray)
                                .opacity(colorScheme == .dark ? 0.3 : 0.3)
                        }
                    }
                    ContentView()
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }
}
