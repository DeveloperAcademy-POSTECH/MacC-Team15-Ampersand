//
//  ScheduleAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct ScheduleAreaView: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    Color.white
                    Path { path in
                        for rowIndex in 0..<viewStore.numOfScheduleAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.scheduleAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.rowStroke)
                    Path { path in
                        for columnIndex in 0..<viewStore.maxCol {
                            let xLocation = CGFloat(columnIndex) * viewStore.gridWidth - viewStore.columnStroke
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray, lineWidth: viewStore.columnStroke)
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            viewStore.send(.magnificationChangedInScheduleArea(value))
                        }
                )
            }
        }
    }
}

struct ScheduleAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleAreaView(store: Store(initialState: PlanBoard.State(rootProject: Project.mock), reducer: { PlanBoard() }))
    }
}
