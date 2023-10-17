//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct TimeAxisAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    // TODO: TimeAxisAreaView (날짜 및 공휴일 상위 뷰에 선언)
    let startDate = Date()
    
    @State private var holidays = [Date]()
    @Binding var leftmostDate: Date
    @Binding var proxy: ScrollViewProxy?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(0..<viewModel.maxCol, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                    let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay(
                            MonthView(month: dateInfo.month)
                                .frame(width: 100)
                                .opacity(dateInfo.isFirstOfMonth || dayOffset == 0 ? 1 : 0)
                                .offset(x: (100 - viewModel.gridWidth) / 2)
                        )
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<viewModel.maxCol, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
                    let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                    DayGridView(dateInfo: dateInfo)
                        .frame(width: viewModel.gridWidth)
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

struct MonthView: View {
    var month: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(month)월")
                    .font(.title2)
                    .padding(.horizontal, 3)
                Spacer()
            }
        }
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
