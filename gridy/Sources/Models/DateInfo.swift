//
//  DateInfo.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import SwiftUI

enum DayOfWeek: String {
    case monday = "월"
    case tuesday = "화"
    case wednesday = "수"
    case thursday = "목"
    case friday = "금"
    case saturday = "토"
    case sunday = "일"
}

 struct DateInfo {
     let date: Date
     let month: String
     let day: String
     let dayOfWeek: DayOfWeek
     let fontColor: Color
     var isHoliday: Bool
     var isFirstOfMonth: Bool

     init(date: Date, isHoliday: Bool) {
         self.date = date
         self.month = self.date.formattedMonth
         self.day = self.date.formattedDay
         self.dayOfWeek = DayOfWeek(rawValue: self.date.dayOfWeek)!
         self.isHoliday = isHoliday
         self.isFirstOfMonth = self.date.formattedDay == "1"

         if self.isHoliday || self.dayOfWeek == DayOfWeek.sunday {
             self.fontColor = Color.red
         } else if self.dayOfWeek == DayOfWeek.saturday {
             self.fontColor = Color.black
         } else {
             self.fontColor = Color.black
         }
     }
 }

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
