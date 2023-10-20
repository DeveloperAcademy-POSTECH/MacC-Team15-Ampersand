//
//  TimelineLayoutView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @State private var showingRightToolBarArea: Bool = true
    @State var showingIndexArea: Bool = true
    @State var proxy: ScrollViewProxy?
    
    var body: some View {
        NavigationSplitView {
            LeftToolBarAreaView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 480)
        } detail: {
            HSplitView {
                TimelineLayoutContentView(showingIndexArea: $showingIndexArea, proxy: $proxy)
                    .environmentObject(viewModel)
                
                if showingRightToolBarArea {
                    RightToolBarAreaView(proxy: $proxy)
                        .environmentObject(viewModel)
                        .frame(width: 240)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Toggle(isOn: $showingRightToolBarArea) {
                    Image(systemName: "sidebar.trailing")
                }
                .toggleStyle(.button)
            }
            ToolbarItem(placement: .cancellationAction) {
                Toggle(isOn: $showingIndexArea) {
                    Image(systemName: "heart")
                }
                .toggleStyle(.button)
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                viewModel.isShiftKeyPressed = event.modifierFlags.contains(.shift)
                return event
            }
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                viewModel.isCommandKeyPressed = event.modifierFlags.contains(.command)
                return event
            }
        }
    }
}

struct TimelineLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutView()
    }
}

