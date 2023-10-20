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
    @StateObject var viewModel = TimelineLayoutViewModel()  // ViewModel 인스턴스 생성
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                //                TimelineLayoutView()
                //                    .environmentObject(viewModel)
            }
        }
        .commands{
            MenuBar(viewModel: viewModel)
        }
        
        
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }
}
