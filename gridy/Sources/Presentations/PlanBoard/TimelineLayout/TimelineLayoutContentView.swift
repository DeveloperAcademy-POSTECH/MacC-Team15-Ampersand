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
        HStack(spacing: 0) {
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
            VStack(spacing: 0) {
                BlackPinkInYourAreaView()
                    .frame(height: 168)
                ListAreaView()
            }
            .frame(minWidth: 266, idealWidth: 266, maxWidth: 266)
            ScrollView(.horizontal) {
                VStack {
                    ScheduleAreaView()
                        .frame(height: 140)
                    TimeAxisAreaView()
                        .frame(height: 28)
                    LineAreaView()
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
