//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
     let startDate = Date().formattedDate
     let numberOfDays = 100

    @State private var holidays: [Date] = []
         @State var scrollOffset = CGFloat.zero
     
     var body: some View {
         VStack {
             HStack {
                 Text("월")
                     .padding()
                     .font(.title)
                 Spacer()
             }
             
             ObservableScrollView(scrollOffset: $scrollOffset) { _ in
                 HStack(spacing: 1) {
                     ForEach(0..<numberOfDays, id: \.self) { dayOffset in
                         let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                         
                         let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                         DayGridView(dateInfo: dateInfo)
                     }
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
        TimeAxisAreaView()
    }
}
