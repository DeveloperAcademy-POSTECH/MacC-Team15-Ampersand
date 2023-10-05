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
         VStack {
             Rectangle()
                 .frame(width: 50, height: 20)
                 .overlay(
                     VStack {
                         Text("\(dateInfo.dayOfWeek)")
                             .foregroundColor(dateInfo.fontColor)
                     }
                 )
             Rectangle()
                 .frame(width: 50, height: 30)
                 .overlay(
                     Text("\(dateInfo.day)일")
                         .foregroundColor(dateInfo.fontColor)
                 )
         }
     }
 }
