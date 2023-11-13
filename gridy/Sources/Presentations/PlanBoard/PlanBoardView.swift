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
                                    .frame(width: 20)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 16,
                                            bottomLeadingRadius: 16,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 0,
                                            style: .continuous
                                        )
                                    )
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlLeft + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        print("left + \(layerIndex) clicked")
                                        // TODO: - layerCreate
                                    }
                                
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
                                    .frame(width: 20)
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 0,
                                            bottomLeadingRadius: 0,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 0,
                                            style: .continuous
                                        )
                                    )
                                    .onHover { isHovered in
                                        viewStore.send(.hoveredItem(name: isHovered ? .layerControlRight + String(layerIndex) : ""))
                                    }
                                    .onTapGesture {
                                        print("right + \(layerIndex) clicked")
                                        // TODO: - layerCreate
                                    }
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
                ZStack {
                    Color.list
                    Path { path in
                        for rowIndex in 0..<viewStore.maxLineAreaRow {
                            let yLocation = CGFloat(rowIndex) * viewStore.lineAreaGridHeight - viewStore.rowStroke
                            path.move(to: CGPoint(x: 0, y: yLocation))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: yLocation))
                        }
                    }
                    .stroke(Color.horizontalLine, lineWidth: viewStore.rowStroke)
                    
                    Path { path in
                        if viewStore.map.count > 1 {
                            let xLocation = (geometry.size.width - viewStore.columnStroke) / 2
                            path.move(to: CGPoint(x: xLocation, y: 0))
                            path.addLine(to: CGPoint(x: xLocation, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.verticalLine, lineWidth: viewStore.columnStroke)
                    
                    if viewStore.isHoveredOnListArea {
                        Rectangle()
                            .fill(.gray.opacity(0.5))
                            .frame(width: 150 - viewStore.columnStroke / 2, height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2)
                            .position(x: CGFloat(Double(viewStore.listAreaHoveredCellCol) + 0.5) * 150 - viewStore.columnStroke / 2, y: CGFloat(Double(viewStore.listAreaHoveredCellRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke)
                            .onTapGesture(count: 2) {
                                viewStore.send(.setHoveredCell(.listArea, false, nil))
                                viewStore.send(.listItemDoubleClicked(true))
                                listItemFocused = true
                            }
                            .opacity((viewStore.selectedListRow == viewStore.listAreaHoveredCellRow)&&(viewStore.selectedListColumn == viewStore.listAreaHoveredCellCol) ? 0 : 1)
                    }
                    
                    if viewStore.listItemSelected {
                        Rectangle()
                            .fill(Color.clear)
                            .overlay(
                                TextField("editing",
                                          text: viewStore.binding(
                                            get: \.keyword,
                                            send: { .keywordChanged($0) }
                                          ))
                                .focused($listItemFocused)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 16)
                                .onSubmit {
                                    // TODO: - createPlanOnList
                                    viewStore.send(
                                        .keywordChanged("")
                                    )
                                    viewStore.send(.listItemDoubleClicked(false))
                                }
                                    .onExitCommand {
                                        viewStore.send(
                                            .keywordChanged("")
                                        )
                                        viewStore.send(.listItemDoubleClicked(false))
                                    }
                            )
                            .frame(width: 150 - viewStore.columnStroke / 2, height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2)
                            .position(x: CGFloat(Double(viewStore.selectedListColumn) + 0.5) * 150 - viewStore.columnStroke / 2, y: CGFloat(Double(viewStore.selectedListRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke)
                    }
                    
                    VStack {
                        ForEach(0..<viewStore.map.count, id: \.self) { layerIndex in
                            let layer = viewStore.map[String(layerIndex)]!
                            ForEach(layer.indices, id: \.self) { rowIndex in
                                ListItemView(store: store, layer: layerIndex, row: rowIndex)
                            }
                        }
                    }
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

struct ListItemView: View {
    let store: StoreOf<PlanBoard>
    let layer: Int
    let row: Int
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    TextField("editing",
                              text: viewStore.binding(
                                get: \.keyword,
                                send: { .keywordChanged($0) }
                              ))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .onSubmit {
                        // TODO: - createPlanOnList
                        viewStore.send(
                            .keywordChanged("")
                        )
                        viewStore.send(.listItemDoubleClicked(false))
                    }
                    .onExitCommand {
                        viewStore.send(
                            .keywordChanged("")
                        )
                        viewStore.send(.listItemDoubleClicked(false))
                    }
                )
                .frame(width: 150 - viewStore.columnStroke / 2, height: viewStore.lineAreaGridHeight - viewStore.rowStroke * 2)
                .position(x: CGFloat(Double(viewStore.listAreaHoveredCellCol) + 0.5) * 150 - viewStore.columnStroke / 2, y: CGFloat(Double(viewStore.listAreaHoveredCellRow) + 0.5) * viewStore.lineAreaGridHeight - viewStore.rowStroke)
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
