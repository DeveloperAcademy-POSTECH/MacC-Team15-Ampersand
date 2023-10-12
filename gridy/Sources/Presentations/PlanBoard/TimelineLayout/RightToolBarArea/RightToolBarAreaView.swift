//
//  RightToolBarAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct RightToolBarAreaView: View {
    @EnvironmentObject var viewModel: TimelineLayoutViewModel
    var body: some View {
        VStack {
            GridSizeControler()
                .environmentObject(viewModel)
                .padding(.top)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct RightToolBarAreaView_Previews: PreviewProvider {
    static var previews: some View {
        RightToolBarAreaView()
    }
}

struct GridSizeControler: View {
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
            
            Text("Mouse on Cell\ncolumn \(viewModel.hoveringCellCol ?? 0), row \(viewModel.hoveringCellRow ?? 0)")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            
            Text("Selected Cell\ncolumn \(viewModel.tappedCellCol ?? 0), row \(viewModel.tappedCellRow ?? 0)")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
        }
    }
}
