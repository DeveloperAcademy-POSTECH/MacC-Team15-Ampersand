//
//  TimelineLayoutView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct TimelineLayoutView: View {
    @State private var showingRightToolBarArea = true
    @State var showingIndexArea = true
    @State var proxy: ScrollViewProxy?
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                LeftToolBarAreaView()
                    .navigationSplitViewColumnWidth(min: 240, ideal: 240, max: 480)
            } detail: {
                HSplitView {
                    TimelineLayoutContentView(showingIndexArea: $showingIndexArea, proxy: $proxy, store: store)
                    
                    if showingRightToolBarArea {
                        RightToolBarAreaView(proxy: $proxy, store: store)
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
                    viewStore.send(.isShiftKeyPressed(event.modifierFlags.contains(.shift)))
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                    viewStore.send(.isCommandKeyPressed(event.modifierFlags.contains(.command)))
                    return event
                }
            }
        }
    }
}

struct TimelineLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
    }
}

