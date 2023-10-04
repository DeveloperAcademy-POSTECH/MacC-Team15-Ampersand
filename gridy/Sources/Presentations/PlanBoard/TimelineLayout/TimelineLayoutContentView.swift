//
//  TimelineLayoutContentView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimelineLayoutContentView: View {
    @Binding var showingIndexArea: Bool
    
    var body: some View {
        VStack(spacing: 0) {
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
                VStack(spacing: 0) {
                    ScheduleAreaView()
                        .frame(height: 140)
                    TimeAxisAreaView()
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
                LineAreaView()
            }
        }
    }
}

struct TimelineLayoutContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineLayoutContentView(showingIndexArea: .constant(true))
    }
}
