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
                ContentView(windowManager: delegate.windowManager)
                    .ignoresSafeArea(.all, edges: .all)
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var windowManager = WindowManager()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
        for window in NSApplication.shared.windows {
            updateMaximizedStatus(window: window)
            let customToolbar = NSToolbar()
            window.toolbar = customToolbar
            window.delegate = self
        }
    }
    func windowDidResize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            updateMaximizedStatus(window: window)
            DispatchQueue.main.async {
                if self.windowManager.isMaximized {
                    window.toolbar = nil
                } else {
                    let customToolbar = NSToolbar()
                    window.toolbar = customToolbar
                }
            }
        }
    }
    private func updateMaximizedStatus(window: NSWindow) {
        let screenSize = window.screen?.visibleFrame.size ?? NSSize.zero
        let windowSize = window.frame.size
        windowManager.isMaximized = (windowSize.width > screenSize.width && windowSize.height > screenSize.height)
    }
}

class WindowManager: ObservableObject {
    @Published var isMaximized = false
}
