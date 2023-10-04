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
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    if showingIndexArea {
                        VStack(spacing: 0) {
                            ScheduleIndexAreaView()
                                .frame(width: 35, height: 140)
                            Rectangle()
                                .foregroundColor(.yellow)
                                .frame(width: 35, height: 35)
                        }
                    }
                    BlackPinkInYourAreaView()
                        .frame(width: 140)
                    VStack(alignment: .leading, spacing: 0) {
                        ScheduleAreaView()
                            .environmentObject(viewModel)
                            .frame(height: 140)
                        TimeAxisAreaView()
                            .environmentObject(viewModel)
                            .frame(height: 35)
                    }
                }
                .frame(height: 175)
                HStack(alignment: .top, spacing: 0) {
                    if showingIndexArea {
                        LineIndexAreaView()
                            .frame(width: 35)
                    }
                    ListAreaView()
                        .frame(width: 140)
                    LineAreaHenryView()
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
