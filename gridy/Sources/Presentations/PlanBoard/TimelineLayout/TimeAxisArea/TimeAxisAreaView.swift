//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel

    // TODO: TimeAxisAreaView (날짜 및 공휴일 전역 선언, ObservableScrollView 해체, ZStack 월 Scroll 안되게)
    let startDate = Date().formattedDate
    let numberOfDays = 200
    
    @State private var holidays: [Date] = []
    @State var scrollOffset = CGFloat.zero
    @State private var leftmostDate = Date()
    
    @State var geometry: GeometryProxy

    var body: some View {
        ZStack(alignment: .topLeading) {
            let visibleCol = Int(geometry.size.width / viewModel.gridWidth)
                HStack(spacing: 0) {
                    ForEach(0..<visibleCol, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                        
                        let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                        DayGridView(dateInfo: dateInfo)
                            .frame(width: viewModel.gridWidth)
                    }
            }
        
            Text("\(leftmostDate.formattedMonth)월")
                .font(.title)
                .padding(.horizontal)
                .background(Color(.blue))
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
//
//struct TimeAxisAreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeAxisAreaView()
//    }
//}
