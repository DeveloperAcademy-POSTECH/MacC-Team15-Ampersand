//
//  RightToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct RightToolBarAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    @Binding var proxy: ScrollViewProxy?
    
    var body: some View {
        GeometryReader { _ in
            GridSizeController()
                .environmentObject(viewModel)
                .padding(.top)
        }
    }
}

struct GridSizeController: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    
    var body: some View {
        VStack {
            Text("Grid Size: width \(Int(viewModel.gridWidth)), height \(Int(viewModel.lineAreaGridHeight))")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            HStack {
                VStack {
                    Text("all")
                    Button(action: {
                                viewModel.gridWidth += 2
                                viewModel.lineAreaGridHeight += 2
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {
                                viewModel.gridWidth -= 2
                                viewModel.lineAreaGridHeight -= 2
                    }) {
                        Image(systemName: "minus")
                    }
                }
                VStack {
                    Text("width")
                    Button(action: {
                                viewModel.gridWidth += 2
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {
                                viewModel.gridWidth -= 2
                    }) {
                        Image(systemName: "minus")
                    }
                }
                VStack {
                    Text("height")
                    Button(action: {
                                viewModel.lineAreaGridHeight += 2
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {
                                viewModel.lineAreaGridHeight -= 2
                    }) {
                        Image(systemName: "minus")
                    }
                }
                VStack {
                    Text("RESET")
                    Button(action: {
                                viewModel.lineAreaGridHeight = 45
                                viewModel.gridWidth = 45
                                viewModel.horizontalMagnification = 1.0
                                viewModel.verticalMagnification = 1.0
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
            Text("Mouse Location\nx \(viewModel.hoverLocation.x), y \(viewModel.hoverLocation.y)")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            
            Text("Mouse on Cell\ncolumn \(viewModel.hoveringCellCol), row \(viewModel.hoveringCellRow)")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            
            if !viewModel.selectedGridRanges.isEmpty {
                Text("SelectedRange Start\ncolumn \(viewModel.selectedGridRanges.last!.start.0), row \(viewModel.selectedGridRanges.last!.start.1)")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                
                Text("SelectedRange End\ncolumn \(viewModel.selectedGridRanges.last!.end.0), row \(viewModel.selectedGridRanges.last!.end.1)")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                Text("exceeded (col, row)\ncolumn \(viewModel.exceededCol), row \(viewModel.exceededRow)")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                if !viewModel.selectedDateRanges.isEmpty {
                    Text("Selected Dates \(viewModel.selectedDateRanges.last!.start.formattedMonth)/\(viewModel.selectedDateRanges.last!.start.formattedDay)~ \(viewModel.selectedDateRanges.last!.end.formattedMonth)/\(viewModel.selectedDateRanges.last!.end.formattedDay)")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
    }
}
