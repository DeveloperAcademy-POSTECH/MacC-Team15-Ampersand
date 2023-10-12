//
//  TimelineLayoutView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutView: View {
    @StateObject var viewModel = TimelineLayoutViewModel()
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
    }
}

struct TimelineLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutView()
    }
}

class TimelineLayoutViewModel: ObservableObject {
    @Published var numOfCol = 60
    @Published var numOfLineAreaRow = 3
    @Published var numOfScheduleAreaRow = 5
    
    let minGridSize: CGFloat = 20
    let maxGridSize: CGFloat = 70
    @Published var gridWidth: CGFloat = 45
    @Published var scheduleAreaGridHeight: CGFloat = 45
    @Published var lineAreaGridHeight: CGFloat = 45
    @Published var horizontalMagnification: CGFloat = 1.0
    @Published var verticalMagnification: CGFloat = 1.0
    
    @Published var hoverLocation: CGPoint = .zero
    @Published var hoveringCellCol: Int = 0
    @Published var hoveringCellRow: Int = 0
    @Published var isHovering = false

    @Published var selectedRanges: [SelectedRange] = []
    
    @Published var exceededCol: Int = 0
    @Published var exceededRow: Int = 0
}

