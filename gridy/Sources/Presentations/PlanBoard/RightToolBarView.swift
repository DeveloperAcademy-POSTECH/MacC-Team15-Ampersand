//
//  RightToolBarView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct RightToolBarView: View {
    
    let store: StoreOf<PlanBoard>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                planBoardBorder(.vertical, 2)
                Color.rightToolBar
                VStack(alignment: .center) {
                    calendarArea
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                    planBoardBorder(.horizontal, 2)
                        .frame(width: geometry.size.width)
                    Text("Task")
                        .padding(12)
                    taskArea
                        .padding(.horizontal, 8)
                }
                Spacer()
            }
            .background(Color.rightToolBar)
        }
    }
}

extension RightToolBarView {
    var calendarArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(viewStore.hoveredItem == "calendarArea" ? Color.lineArea : .item)
                .frame(width: 248, height: 248)
                .overlay {
                    GeometryReader { _ in
                        VStack(alignment: .center, spacing: 4) {
                            HStack(alignment: .center, spacing: 16) {
                                Text("\(viewStore.currentDate.formattedMonth) 월")
                                    .foregroundStyle(Color.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.body)
                                    .foregroundColor(Color.title)
                                    .onTapGesture { viewStore.send(.changeMonth(monthIndex: -1))}
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .foregroundColor(Color.title)
                                    .onTapGesture { viewStore.send(.changeMonth(monthIndex: 1))}
                            }
                            .padding(.horizontal, 24)
                            HStack(alignment: .top, spacing: 5) {
                                ForEach(viewStore.days, id: \.self) { day in
                                    Text(day)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(day == "일" ? Color.subtitle : .title)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            let columns = Array(
                                repeating: GridItem(
                                    .fixed(25),
                                    spacing: 5
                                ),
                                count: 7
                            )
                            LazyVGrid(
                                columns: columns,
                                spacing: viewStore.currentDate.extractDate().count > 35 ? 0 : 6)
                            {
                                ForEach(viewStore.currentDate.extractDate()) { value in
                                    cardView(value: value)
                                }
                            }
                            Spacer()
                        }
                    }
                    .offset(y: 24)
                }
                .scaleEffect(viewStore.hoveredItem == "calendarArea" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "calendarArea" : ""))
                }
        }
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isToday = Calendar.current.isDateInToday(value.date)
                let isSunday = value.date.dayOfSunday() == 1
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(isToday ? Color.title : .clear)
                Text("\(value.day)")
                    .font(.title3)
                    .bold(isToday ? true : false)
                    .foregroundColor(isSunday ? Color.subtitle : isToday ? Color.white : .title)
            }
        }
    }
}

extension RightToolBarView {
    var taskArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if !viewStore.currentModifyingPlanID.isEmpty,
               let selectedPlan = viewStore.existingPlans[viewStore.currentModifyingPlanID],
               let selectedPlanType = viewStore.existingPlanTypes[selectedPlan.planTypeID] {
                RoundedRectangle(cornerRadius: 12)
                    .overlay {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color(hex: selectedPlanType.colorCode))
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 0.5)
                                    )
                                RoundedRectangle(cornerRadius: 8)
                                    .overlay {
                                        Text("Layer1/Layer2")
                                            .foregroundColor(Color.rightToolBarText)
                                    }
                                    .frame(width: 93, height: 22)
                                    .foregroundColor(Color.rightToolBarArea)
                                Spacer()
                                RoundedRectangle(cornerRadius: 8)
                                    .overlay {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .foregroundColor(Color.rightToolBarText)
                                            .frame(width: 14, height: 14)
                                    }
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.rightToolBarArea)
                                    .padding(.trailing, 12)
                            }
                            .padding(.leading, 12)
                            HStack {
                                Text(selectedPlanType.title)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.title)
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 15, height: 16)
                                    .foregroundColor(Color.subtitle)
                            }
                            .padding(.leading, 16)
                            
                            Text("Write down description\n")
                                .lineLimit(2)
                                .frame(width: 212, height: 64)
                                .foregroundColor(Color.rightToolBarTask)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.subtitle, lineWidth: 1)
                                        .foregroundColor(Color.rightToolBarText)
                                )
                                .padding(.horizontal, 8)

                            HStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .overlay {
                                        if let currentModifyingPlanPeriod = viewStore.currentModifyingPlanPeriod {
                                            Text(currentModifyingPlanPeriod.start.formattedDate)
                                                .foregroundColor(Color.rightToolBarText)
                                        }
                                    }
                                    .foregroundColor(Color.rightToolBarArea)
                                    .frame(height: 24)
                                Text("~")
                                    .foregroundColor(Color.rightToolBarText)
                                RoundedRectangle(cornerRadius: 6)
                                    .overlay {
                                        if let currentModifyingPlanPeriod = viewStore.currentModifyingPlanPeriod {
                                            Text(currentModifyingPlanPeriod.end.formattedDate)
                                                .foregroundColor(Color.rightToolBarText)
                                        }
                                    }
                                    .foregroundColor(Color.rightToolBarArea)
                                    .frame(height: 24)
                                
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .frame(width: 248, height: 187)
                    .foregroundColor(Color.rightToolBarBackground)
            }
        }
    }
}
