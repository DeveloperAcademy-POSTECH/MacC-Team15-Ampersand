//
//  CalendarView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/3/23.
//

import SwiftUI

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

struct CalendarView: View {
    @State private var currentDate = Date()
    @State private var currentMonth = 0
    @State private var isDayClicked = false
    @State private var selectedDate = DateValue(day: 0, date: Date())
    @State private var startDate: DateValue?
    @State private var endDate: DateValue?
    @State private var dates = [DateValue]()
    
    var body: some View {
        
        let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        let columns = Array(repeating: GridItem(.fixed(22)), count: 7)
        
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(Color.item)
                .padding()
            VStack(alignment: .center) {
                HStack(spacing: 16) {
                    Text(nowDate()[1])
                        .foregroundStyle(Color.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .foregroundStyle(Color.subtitle)
                        .onTapGesture {
                            currentMonth -= 1
                            currentDate = getCurrentMonth()
                            dates = extractDate()
                        }
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(Color.subtitle)
                        .onTapGesture {
                            currentMonth += 1
                            currentDate = getCurrentMonth()
                            dates = extractDate()
                        }
                }
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(day == "일" ? Color.subtitle : Color.title)
                            .frame(width: 22, height: 22)
                    }
                }
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(dates) { value in
                        cardView(value: value)
                    }
                }
                .onAppear {
                    dates = extractDate()
                }
            }
            .fixedSize()
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        let columnWidth: CGFloat = 37
        let rowHeight: CGFloat = 37
        
        ZStack {
            if value.day != -1 {
                if let startDate = startDate, let endDate = endDate,
                   let startIndex = dates.firstIndex(where: { $0.id == startDate.id }),
                   let endIndex = dates.firstIndex(where: { $0.id == endDate.id }),
                   let valueIndex = dates.firstIndex(where: { $0.id == value.id }),
                   valueIndex >= startIndex, valueIndex <= endIndex {
                    
                    if valueIndex != startIndex && valueIndex != endIndex {
                        if valueIndex == startIndex + 1 {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: columnWidth, height: rowHeight*3/4)
                                .offset(x: columnWidth/3, y: 0)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: columnWidth, height: rowHeight*3/4)
                        }
                    }
                    
                    if valueIndex == startIndex || valueIndex == endIndex {
                        if valueIndex == startIndex {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: columnWidth, height: rowHeight)
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: columnWidth/2, height: rowHeight*3/4)
                                .offset(x: columnWidth/2, y: 0)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: columnWidth/2, height: rowHeight*3/4)
                                .offset(x: -columnWidth / 4, y: 0)
                        }
                    }
                }
                
                Text("\(value.day)")
                    .font(.title3)
                    .foregroundColor(isSelectedDate(value.date) ? Color.white : (value.date.dayOfSunday() == 1 ? Color.subtitle : Color.black))
                    .frame(width: columnWidth, height: rowHeight)
                    .background((startDate?.date == value.date || endDate?.date == value.date) ? Color.black : Color.clear)
                    .cornerRadius(rowHeight / 2)
                    .onTapGesture {
                        selectDate(value)
                    }
            }
        }
    }
    
    private func nowDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    private func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    private func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
    private func selectDate(_ value: DateValue) {
        if startDate == nil {
            startDate = value
        } else if endDate == nil {
            if let start = startDate, start.date > value.date {
                endDate = startDate
                startDate = value
            } else {
                endDate = value
            }
        } else {
            startDate = value
            endDate = nil
        }
    }
    
    private func isSelectedDate(_ date: Date) -> Bool {
        if let start = startDate?.date, let end = endDate?.date {
            return (start...end).contains(date)
        } else {
            return startDate?.date == date || endDate?.date == date
        }
    }
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        var range = calendar.range(of: .day, in: .month, for: startDate)!
        range.removeLast()
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    func dayOfSunday() -> Int? {
        let calendar = Calendar.current
        return calendar.dateComponents([.weekday], from: self).weekday
    }
}

#Preview {
    CalendarView()
}
