//
//  DayGridView.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import SwiftUI

struct DayGridView: View {
    let dateInfo: DateInfo
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.gray.opacity(0.3))
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                    .frame(width: 0.5)
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                        .frame(height: 3)
                    VStack {
                        Rectangle()
                            .foregroundStyle(.white)
                            .overlay(
                                Text("\(dateInfo.day)")
                                    .foregroundColor(dateInfo.fontColor)
                            )
                        Spacer()
                            .frame(height: 1)
                        Rectangle()
                            .foregroundStyle(.white.opacity(0.5))
                            .overlay(
                                Text("\(dateInfo.dayOfWeek.rawValue)")
                                    .foregroundColor(dateInfo.fontColor)
                            )
                    }
                    .border(.red.opacity(dateInfo.date.formattedDate == Date().formattedDate ? 1 : 0), width: 1.5)
                    Spacer()
                        .frame(height: 3)
                }
                Spacer()
                    .frame(width: 0.5)
            }
        }
    }
}

