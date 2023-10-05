//
//  Date+Extension.swift
//  gridy
//
//  Created by SY AN on 2023/10/05.
//

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
        Date.dateFormatter.locale = Locale(identifier: "ko_KR")
        return Date.dateFormatter.string(from: self)
    }

    var formattedDate: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
