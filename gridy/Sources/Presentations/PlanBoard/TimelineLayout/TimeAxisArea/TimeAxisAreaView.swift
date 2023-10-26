//
//  TimeAxisAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct TimeAxisAreaView: View {
    // TODO: TimeAxisAreaView (날짜 및 공휴일 상위 뷰에 선언)
    let startDate = Date()

    @State private var holidays = [Date]()
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<viewStore.maxCol, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset + viewStore.shiftedCol, to: startDate)!
                        let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                        Rectangle()
                            .foregroundStyle(.clear)
                            .overlay(
                                MonthView(month: dateInfo.month)
                                    .frame(width: 100)
                                    .opacity(dateInfo.isFirstOfMonth || dayOffset == 0 ? 1 : 0)
                                    .offset(x: (100 - viewStore.gridWidth) / 2)
                            )
                    }
                }
                HStack(spacing: 0) {
                    ForEach(0..<viewStore.maxCol, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: dayOffset + viewStore.shiftedCol, to: startDate)!
                        let dateInfo = DateInfo(date: date, isHoliday: holidays.contains(date))
                        DayGridView(dateInfo: dateInfo)
                            .frame(width: viewStore.gridWidth)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
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
}

struct MonthView: View {
    var month: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(month)월")
                    .foregroundStyle(.black)
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
