//
//  Date+Extension.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

import Foundation

extension Date {
    private static let dateFormatter = DateFormatter()

    var formattedMonth: String {
        Date.dateFormatter.dateFormat = "M"
        return Date.dateFormatter.string(from: self)
    }

    var formattedDay: String {
        Date.dateFormatter.dateFormat = "d"
        return Date.dateFormatter.string(from: self)
    }

    var dayOfWeek: String {
        Date.dateFormatter.dateFormat = "E"
        return Date.dateFormatter.string(from: self)
    }
    
    var formattedDate: String {
        Date.dateFormatter.dateFormat = "yyyy.MM.dd"
        return Date.dateFormatter.string(from: self)
    }

    var filteredDate: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var integerDate: Int {
        Int(self.timeIntervalSince1970) / 86400
    }
    
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        var range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    func dayOfSunday() -> Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.weekday], from: self).weekday
    }
    
    func moveMonth(movedMonth: Int) -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: movedMonth, to: self) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        var startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        var days = startDate.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}
