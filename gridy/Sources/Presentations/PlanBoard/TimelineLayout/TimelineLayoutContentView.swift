//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @Binding var showingIndexArea: Bool
    @State private var visibleCol: Int = 0
    @State private var visibleLineAreaRow: Int = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if showingIndexArea {
                VStack(spacing: 0) {
                    ScheduleIndexAreaView()
                        .frame(height: 140)
                    Rectangle()
                        .frame(height: 28)
                    LineIndexAreaView()
                }
                .frame(width: 35)
            }
            VStack(alignment: .leading, spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 168)
                ListAreaView()
            }
            .frame(width: 140)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 0) {
                    ScheduleAreaView()
                        .frame(height: 140)
                    
                    TimeAxisAreaView()
                        .environmentObject(viewModel)
                        .frame(height: 80)
                    
                    LineAreaSampleView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct TimelineLayoutContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutContentView(showingIndexArea: .constant(true))
    }
}
