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
            Text("\(dateInfo.month)월")
                .font(.title)
                .opacity(dateInfo.isFirstOfMonth ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .frame(width: 50, height: 20)
                    .overlay(
                        Text("\(dateInfo.dayOfWeek)")
                            .foregroundColor(dateInfo.fontColor)
                    )
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 0.3).frame(height: 1), alignment: .bottom)
                
                Rectangle()
                    .frame(width: 50, height: 30)
                    .overlay(
                        Text("\(dateInfo.day)일")
                            .foregroundColor(dateInfo.fontColor)
                    )
            }
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: dateInfo.dayOfWeek == "토" ? 0.5 : 0.2)
                    .frame(width: 1), alignment: .trailing
            )
        }
    }
}
