//
//  TimelineLayoutView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

@available(macOS 14.0, *)
struct TimelineLayoutView: View {
    @State private var showingRightToolBarArea: Bool = true
    
    var body: some View {
        NavigationSplitView {
            LeftToolBarAreaView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 480)
        } detail: {
            TimelineLayoutContentView()
                .inspector(isPresented: $showingRightToolBarArea) {
                    RightToolBarAreaView()
                        .inspectorColumnWidth(240)
                }
        }
        .toolbar {
            Toggle(isOn: $showingRightToolBarArea) {
                Image(systemName: "sidebar.trailing")
            }
            .toggleStyle(.button)
        }
    }
}

@available(macOS 14.0, *)
struct TimelineLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutView()
    }
}
