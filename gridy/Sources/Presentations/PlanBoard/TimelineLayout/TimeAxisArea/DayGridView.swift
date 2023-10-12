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
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .frame(width: 50, height: 15)
                    .overlay(
                        Text("\(dateInfo.dayOfWeek.rawValue)")
                            .foregroundColor(dateInfo.fontColor)
                    )
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 0.3).frame(height: 1), alignment: .bottom)
                
                Rectangle()
                    .frame(width: 50, height: 15)
                    .overlay(
                        Text("\(dateInfo.day)일")
                            .foregroundColor(dateInfo.fontColor)
                    )
            }
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: dateInfo.dayOfWeek == DayOfWeek.saturday ? 0.5 : 0.2)
                    .frame(width: 1), alignment: .trailing
            )
            .overlay(
                Rectangle()
                    .strokeBorder(Color.red, lineWidth: dateInfo.date.formattedDate == Date().formattedDate ? 1.5 : 0)
            )
        }
}
