//
//  DateInfo.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import SwiftUI

 struct DateInfo {
     let date: Date
     let month: String
     let day: String
     let dayOfWeek: String
     let fontColor: Color
     var isHoliday: Bool

     init(date: Date, isHoliday: Bool) {
         self.date = date

         self.month = self.date.formattedMonth

         self.day = self.date.formattedDay

         self.dayOfWeek = self.date.dayOfWeek

         self.isHoliday = isHoliday

         // 요일에 따라 다른 텍스트 색상 설정
         if self.isHoliday || self.dayOfWeek == "일" {
             self.fontColor = Color.red
         } else if self.dayOfWeek == "토" {
             self.fontColor = Color.blue
         } else {
             self.fontColor = Color.black
         }
     }
 }
