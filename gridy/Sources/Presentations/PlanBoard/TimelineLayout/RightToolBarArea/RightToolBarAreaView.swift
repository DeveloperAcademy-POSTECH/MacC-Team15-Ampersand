//
//  RightToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI
import ComposableArchitecture

struct RightToolBarAreaView: View {
    @Binding var proxy: ScrollViewProxy?
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        GeometryReader { _ in
            GridSizeController(store: store)
                .padding(.top)
        }
    }
}

struct GridSizeController: View {
    
    let store: StoreOf<PlanBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("Grid Size: width \(Int(viewStore.gridWidth)), height \(Int(viewStore.lineAreaGridHeight))")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                HStack {
                    VStack {
                        Text("all")
                        Button(action: {
                            viewStore.send(.changeWidthButtonTapped(2))
                            viewStore.send(.changeHeightButtonTapped(2))
                        }) {
                            Image(systemName: "plus")
                        }
                        Button(action: {
                            viewStore.send(.changeWidthButtonTapped(-2))
                            viewStore.send(.changeHeightButtonTapped(-2))
                        }) {
                            Image(systemName: "minus")
                        }
                    }
                    VStack {
                        Text("width")
                        Button(action: {
                            viewStore.send(.changeWidthButtonTapped(2))
                        }) {
                            Image(systemName: "plus")
                        }
                        Button(action: {
                            viewStore.send(.changeWidthButtonTapped(-2))
                        }) {
                            Image(systemName: "minus")
                        }
                    }
                    VStack {
                        Text("height")
                        Button(action: {
                            viewStore.send(.changeHeightButtonTapped(2))
                        }) {
                            Image(systemName: "plus")
                        }
                        Button(action: {
                            viewStore.send(.changeHeightButtonTapped(-2))
                        }) {
                            Image(systemName: "minus")
                        }
                    }
                    VStack {
                        Text("RESET")
                        Button(action: {
                            viewStore.send(.changeHeightButtonTapped(-viewStore.lineAreaGridHeight + 45))
                            viewStore.send(.changeWidthButtonTapped(-viewStore.gridWidth + 45))
//                                    viewStore.horizontalMagnification = 1.0
//                                    viewStore.verticalMagnification = 1.0
                        }) {
                            Image(systemName: "gobackward")
                        }
                        Button(action: {
                        }) {
                            Image(systemName: "gobackward")
                                .foregroundColor(.clear)
                        }
                    }
                    
                }
                Text("Mouse Location\nx \(viewStore.hoverLocation.x), y \(viewStore.hoverLocation.y)")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                
                Text("Mouse on Cell\ncolumn \(viewStore.hoveringCellCol), row \(viewStore.hoveringCellRow)")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                
                if !viewStore.selectedGridRanges.isEmpty {
                    Text("SelectedRange Start\nrow \(viewStore.selectedGridRanges.last!.start.0), column \(viewStore.selectedGridRanges.last!.start.1)")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    
                    Text("SelectedRange End\nrow \(viewStore.selectedGridRanges.last!.end.0), column \(viewStore.selectedGridRanges.last!.end.1)")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    Text("shifted (col, row)\ncolumn \(viewStore.shiftedCol), row \(viewStore.shiftedRow)")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    if !viewStore.selectedDateRanges.isEmpty {
                        Text("Selected Dates \(viewStore.selectedDateRanges.last!.start.formattedMonth)/\(viewStore.selectedDateRanges.last!.start.formattedDay)~ \(viewStore.selectedDateRanges.last!.end.formattedMonth)/\(viewStore.selectedDateRanges.last!.end.formattedDay)")
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
