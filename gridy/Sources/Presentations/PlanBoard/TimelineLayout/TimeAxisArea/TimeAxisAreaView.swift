//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    // TODO: TimeAxisAreaView (날짜 및 공휴일 전역 선언)
    let startDate = Date().formattedDate
    let numberOfDays = 200
    
    @State private var holidays: [Date] = []
    @Binding var leftmostDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: MonthView(month: leftmostDate.formattedMonth).background(.gray)) {
                    ForEach(1..<numberOfDays, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                        let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                        
                        MonthView(month: dateInfo.month)
                        .opacity(dateInfo.isFirstOfMonth ? 1 : 0)                    }
                }
            }
            
            LazyHStack(spacing: 0) {
                ForEach(0..<numberOfDays, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                    let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                    
                    DayGridView(dateInfo: dateInfo)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let fetchedHolidays = try await fetchKoreanHolidays()
                    
                    holidays = fetchedHolidays
                } catch {
                    print("오류 발생: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct TimeAxisAreaView_Previews: PreviewProvider {
    static var previews: some View {
        TimeAxisAreaView(leftmostDate: .constant(Date()))
    }
}

struct MonthView: View {
    var month: String
    
    var body: some View {
        Text("\(month)월")
            .frame(width: 50)
    }
}
