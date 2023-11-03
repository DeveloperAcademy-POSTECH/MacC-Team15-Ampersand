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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(Color.item)
                .padding()
            VStack(alignment: .center) {
                let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
                HStack(spacing: 16) {
                    Text(extraDate()[1])
                        .foregroundStyle(Color.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .foregroundColor(Color.subtitle)
                        .onTapGesture {
                            currentMonth -= 1
                        }
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(Color.subtitle)
                        .onTapGesture {
                            currentMonth += 1
                        }
                }
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(day == "일" ? Color.subtitle : Color.title)
                            .frame(width: 22, height: 22)
                    }
                }
                let columns = Array(repeating: GridItem(.fixed(22)), count: 7)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(extractDate()) { value in
                        ZStack {
                            cardView(value: value)
                        }
                    }
                }
                .onChange(of: currentMonth) { _ in
                    currentDate = getCurrentMonth()
                }
            }
            .fixedSize()
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isToday = Calendar.current.isDateInToday(value.date)
                let comparisonResult = Calendar.current.compare(value.date, to: Date(), toGranularity: .day)
                let isSunday = value.date.dayOfSunday() == 1  // 1은 일요일을 나타냅니다.
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(isToday ? Color.item : .clear)
                Text("\(value.day)")
                    .font(.title3)
                    .bold(isToday ? true : false)
                    .foregroundColor(isSunday ? Color.subtitle : (isToday ? Color.itemSelected : Color.title))
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
    
    func getCurrentMonth() -> Date  {
        let calendar = Calendar.current
        //현재 달의 요일을 받아옴
        guard let currentMonth = calendar.date(byAdding: .month, value:  self.currentMonth,to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        //현재 달의 요일을 받아옴
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
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
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

