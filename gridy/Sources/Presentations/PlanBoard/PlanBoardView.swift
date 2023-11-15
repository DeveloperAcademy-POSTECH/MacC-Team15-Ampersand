//
//  PlanBoardView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/2/23.
//

import SwiftUI
import ComposableArchitecture

struct PlanBoardView: View {
    @State private var temporarySelectedGridRange: SelectedGridRange?
    @State private var exceededDirection = [false, false, false, false]
    @State private var timer: Timer?
    @FocusState var listItemFocused: Bool
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                systemBorder(.horizontal)
                TopToolBarView(store: store)
                    .frame(height: 48)
                    .zIndex(2)
                planBoardBorder(.horizontal)
                HStack(alignment: .top, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            scheduleIndexArea
                                .frame(height: 143)
                            planBoardBorder(.horizontal)
                            extraArea
                                .frame(height: 48)
                            planBoardBorder(.horizontal)
                            lineIndexArea
                        }
                        .frame(width: 20)
                        planBoardBorder(.vertical)
                        VStack(alignment: .leading, spacing: 0) {
                            blackPinkInYourArea
                                .frame(height: 143)
                            planBoardBorder(.horizontal)
                            listControlArea
                                .frame(height: 48)
                            planBoardBorder(.horizontal)
                            listArea
                        }
                        .frame(width: 150 * CGFloat(viewStore.map.count))
                        planBoardBorder(.vertical)
                    }
                    .zIndex(1)
                    .background(
                        Color.white
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 8,
                                x: 4
                            )
                    )
                    GeometryReader { _ in
                        VStack(alignment: .leading, spacing: 0) {
                            scheduleArea
                                .frame(height: 143)
                            planBoardBorder(.horizontal)
                            timeAxisArea
                                .frame(height: 48)
                            planBoardBorder(.horizontal)
                            lineArea
                        }
                    }
                    if viewStore.isRightToolBarPresented {
                        RightToolBarView()
                            .frame(width: 240)
                            .zIndex(1)
                            .background(
                                Color.white
                                    .shadow(
                                        color: .black.opacity(0.25),
                                        radius: 8,
                                        x: -4
                                    )
                            )
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

extension PlanBoardView {
    var scheduleIndexArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var extraArea: some View {
        Color.index
    }
}

extension PlanBoardView {
    var lineIndexArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    Color.index
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                }
            }
        }
    }
}

extension PlanBoardView {
    var blackPinkInYourArea: some View {
        Color.listItem
    }
}

extension PlanBoardView {
    var listControlArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.list
                HStack {
                    ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                        VStack {
                            Spacer()
                            HStack(alignment: .center, spacing: 0) {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(
                                        Image(systemName: "chevron.left")
                                            .fontWeight(.bold)
                                            .foregroundStyle(viewStore.hoveredItem == .layerControlLeft + String(layerIndex) ? .red : .red.opacity(0.5))
                                    )
                                    .frame(width: 25)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlLeft + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        viewStore.send(.createLayerButtonClicked(layer: layerIndex))
                                    }
//                                    .disabled(viewStore.map.count > 1)
                                
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlButton + String(layerIndex) : ""))
                                    }
                                
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .overlay(
                                        Image(systemName: "chevron.right")
                                            .fontWeight(.bold)
                                            .foregroundStyle(viewStore.hoveredItem == .layerControlRight + String(layerIndex) ? .blue : .blue.opacity(0.5))
                                    )
                                    .frame(width: 25)
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlRight + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        viewStore.send(.createLayerButtonClicked(layer: layerIndex + 1))
                                    }
//                                    .disabled(viewStore.map.count > 1)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundStyle(viewStore.hoveredItem.contains("layerControl") && viewStore.hoveredItem.contains(String(layerIndex)) ?
                                                     Color.itemHovered : .item
                                    )
                            }
                            .frame(height: 20)
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var listArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    Color.list
                    Path { path in
                        for rowIndex in 1...viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    
                    Path { path in
                        if viewStore.map.count > 1 {
                            let xLocation = geometry.size.width / 2
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
                    
                    let gridWidth = (geometry.size.width - viewStore.columnStroke * CGFloat(viewStore.map.count - 1)) / CGFloat(viewStore.map.count)
                    /// hover 되었을 때
                    if viewStore.isHoveredOnListArea {
                        Rectangle()
                            .fill(Color.itemHovered)
                            .frame(
                                width: gridWidth,
                                height: viewStore.lineAreaGridHeight - viewStore.rowStroke
                            )
                            .position(x: gridWidth / 2 + (gridWidth + viewStore.columnStroke) * CGFloat(viewStore.listAreaHoveredCellCol),
                                      y: CGFloat(Double(viewStore.listAreaHoveredCellRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke / 2)
                            .onTapGesture {
                                
                            }
                            .highPriorityGesture(TapGesture(count: 2).onEnded({
                                listItemFocused = true
                                viewStore.send(.listItemDoubleClicked(.listItem, false))
                                viewStore.send(.listItemDoubleClicked(.emptyListItem, true))
                                viewStore.send(.setHoveredCell(.listArea, false, nil))
                            }))
                            .opacity((viewStore.selectedEmptyRow == viewStore.listAreaHoveredCellRow)&&(viewStore.selectedEmptyColumn == viewStore.listAreaHoveredCellCol) ? 0 : 1)
                    }
                    
                    /// double click 되었을 때
                    if let columnOffset = viewStore.selectedEmptyColumn, let rowOffset = viewStore.selectedEmptyRow {
                        Rectangle()
                            .fill(Color.clear)
                            .overlay(
                                TextField("editing",
                                          text: viewStore.binding(
                                            get: \.keyword,
                                            send: { .keywordChanged($0) }
                                          ))
                                .focused($listItemFocused)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 16)
                                .onSubmit {
                                    viewStore.send(.createPlanOnList(
                                        layer: viewStore.selectedEmptyColumn!,
                                        row: viewStore.selectedEmptyRow!,
                                        text: viewStore.keyword,
                                        colorCode: PlanType.emptyPlanType.colorCode)
                                    )
                                    viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                }
                                .onExitCommand {
                                    viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                }
                            )
                            .frame(width: 150 - viewStore.columnStroke / 2, height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2)
                            .position(x: CGFloat(Double(columnOffset) + 0.5) * 150 - viewStore.columnStroke / 2, y: CGFloat(Double(rowOffset) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke)
                    }
                    /// map에 있는 정보
                    listMap
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        viewStore.send(.setHoveredCell(.listArea, true, location))
                    case .ended:
                        viewStore.send(.setHoveredCell(.listArea, false, nil))
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var listMap: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                let gridWidth = (geometry.size.width - viewStore.columnStroke * CGFloat(viewStore.map.count - 1)) / CGFloat(viewStore.map.count)
                
                HStack(alignment: .top, spacing: viewStore.columnStroke) {
                    ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                        let layer = viewStore.map[layerIndex]
                        VStack(alignment: .leading, spacing: viewStore.rowStroke) {
                            ForEach(layer.indices, id: \.self) { rowIndex in
                                /// doubleClick 되었을 떄
                                if viewStore.selectedListRow == rowIndex && viewStore.selectedListColumn == layerIndex {
                                    Rectangle()
                                        .fill(Color.list)
                                        .overlay(
                                            TextField("editing",
                                                      text: viewStore.binding(
                                                        get: \.keyword,
                                                        send: { .keywordChanged($0) }
                                                      ))
                                            .focused($listItemFocused)
                                            .multilineTextAlignment(.center)
                                            .textFieldStyle(.plain)
                                            .padding(.horizontal, 16)
                                            .onSubmit {
                                                viewStore.send(.updatePlanTypeOnList(
                                                    targetPlanID: layer[rowIndex],
                                                    text: viewStore.keyword,
                                                    colorCode: PlanType.emptyPlanType.colorCode
                                                ))
                                                viewStore.send(.listItemDoubleClicked(.listItem, false))
                                            }
                                            .onExitCommand {
                                                viewStore.send(.listItemDoubleClicked(.listItem, false))
                                            }
                                        )
                                } else {
                                    Rectangle()
                                        .fill(viewStore.listAreaHoveredCellCol == layerIndex && viewStore.listAreaHoveredCellRow == rowIndex ? Color.itemHovered : Color.list)
                                        .overlay {
                                            let planID = viewStore.map[layerIndex][rowIndex]
                                            let planTypeID = viewStore.existingPlans[planID]!.planTypeID
                                            
                                            Text("\(viewStore.existingPlanTypes[planTypeID]!.title)")
                                        }
                                        .onTapGesture(count: 2) {
                                            listItemFocused = true
                                            viewStore.send(.listItemDoubleClicked(.emptyListItem, false))
                                            viewStore.send(.listItemDoubleClicked(.listItem, true))
                                        }
                                }
                            }
                            .frame(
                                width: gridWidth,
                                height: viewStore.lineAreaGridHeight - viewStore.rowStroke
                            )
                        }
                    }
                }
            }
        }
    }
}

extension PlanBoardView {
    var scheduleArea: some View {
        Color.lineArea
    }
}

extension PlanBoardView {
    var timeAxisArea: some View {
        Color.lineArea
    }
}

extension PlanBoardView {
    var lineArea: some View {
        Color.lineArea
    }
}
