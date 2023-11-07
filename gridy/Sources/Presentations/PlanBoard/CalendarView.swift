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
    @State private var currentDate: Date = Date()
    @State private var currentMonth: Int = 0
    @State private var isDayClicked: Bool = false
    @State private var selectedDate: DateValue = DateValue(day: 0, date: Date())
    let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .foregroundStyle(.white)
            .frame(width: 248, height: 248)
            .overlay {
                GeometryReader { _ in
                    VStack(alignment: .center, spacing: 4) {
                        HStack(alignment: .center, spacing: 16) {
                            Text(extraDate()[1])
                                .foregroundStyle(Color.black)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.left")
                                .font(.body)
                                .foregroundColor(Color.gray)
                                .onTapGesture {
                                    currentMonth -= 1
                                }
                            Image(systemName: "chevron.right")
                                .font(.body)
                                .foregroundColor(Color.gray)
                                .onTapGesture {
                                    currentMonth += 1
                                }
                        }
                        .padding(.horizontal, 24)
                        HStack(alignment: .top, spacing: 5) {
                            ForEach(days, id: \.self) { day in
                                Text(day)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(day == "일" ? Color.gray : Color.black)
                                    .frame(width: 25, height: 25)
                            }
                        }
                        let columns = Array(repeating: GridItem(.fixed(25), spacing: 5), count: 7)
                        LazyVGrid(columns: columns, spacing: extractDate().count > 35 ? 0 : 6) {
                            ForEach(extractDate()) { value in
                                cardView(value: value)
                            }
                        }
                        .onChange(of: currentMonth) { _ in
                            currentDate = getCurrentMonth()
                        }
                        Spacer()
                    }
                }
                .offset(y: 24)
            }
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isToday = Calendar.current.isDateInToday(value.date)
                let comparisonResult = Calendar.current.compare(value.date, to: Date(), toGranularity: .day)
                let isSunday = value.date.dayOfSunday() == 1
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(isToday ? Color.black : .clear)
                Text("\(value.day)")
                    .font(.title3)
                    .bold(isToday ? true : false)
                    .foregroundColor(isSunday ? Color.gray : isToday ? Color.white : Color.black)
            }
        }
    }
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        /// 현재 달의 요일을 받아옴
        guard let currentMonth = calendar.date(byAdding: .month, value : self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
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
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        var range = calendar.range(of: .day, in: .month, for: startDate)!
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

