//
//  LineAreaHenryView.swift
//  gridy
//
//  Created by 최민규 on 2023/10/04.
//

import SwiftUI

struct LineAreaHenryView: View {
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple]
    @State private var gridWidth: CGFloat = 25
    @State private var gridHeight: CGFloat = 25
    
    @State private var tappedPoint: CGPoint? = nil
    
    @State private var hoverLocation: CGPoint = .zero
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            GridSizeControl(gridWidth: $gridWidth, gridHeight: $gridHeight)
            
            Text("Mouse Location: x \(hoverLocation.x), y \(hoverLocation.y)")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            
            Text("Mouse on Grid: column \(Int(hoverLocation.x / gridWidth)), row \(Int(hoverLocation.y / gridHeight))")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        HStack(spacing: 0) { // Remove spacing between columns
                            ForEach(0..<30, id: \.self) { col in
                                VStack(spacing: 0) { // Remove spacing between rows
                                    ForEach(0..<20, id: \.self) { row in
                                        Rectangle()
                                            .foregroundColor(colors[(row + col) % colors.count])
                                            .frame(width: gridWidth, height: gridHeight)
                                            .onTapGesture { gesture in
                                                let rectTopLeft = CGPoint(x: CGFloat(col) * gridWidth, y: CGFloat(row) * gridHeight)
                                                tappedPoint = rectTopLeft
                                                print("Top-left corner of the rectangle at column \(col), row \(row): \(tappedPoint.debugDescription)")
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoverLocation = location
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
            .overlay {
                if isHovering {
                    Circle()
                        .fill(.white)
                        .opacity(0.5)
                        .frame(width: 30, height: 30)
                        .position(x: hoverLocation.x, y: hoverLocation.y)
                }
            }
        }
    }
}

struct LineAreaHenryView_Previews: PreviewProvider {
    static var previews: some View {
        LineAreaHenryView()
            .previewLayout(.fixed(width: 1000, height: 500))
    }
}

struct GridSizeControl: View {
    @Binding var gridWidth: CGFloat
    @Binding var gridHeight: CGFloat
    var body: some View {
        VStack {
            Text("Grid Size: width \(Int(gridWidth)), height \(Int(gridHeight))")
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            HStack {
                VStack {
                    Text("all")
                    Button(action: {
                        gridWidth += 1
                        gridHeight += 1
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                    Button(action: {
                        gridWidth -= 1
                        gridHeight -= 1
                    }) {
                        Image(systemName: "minus")
                            .padding()
                    }
                }
                VStack {
                    Text("width")
                    Button(action: {
                        gridWidth += 1
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                    Button(action: {
                        gridWidth -= 1
                    }) {
                        Image(systemName: "minus")
                            .padding()
                    }
                }
                VStack {
                    Text("height")
                    Button(action: {
                        gridHeight += 1
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                    Button(action: {
                        gridHeight -= 1
                    }) {
                        Image(systemName: "minus")
                            .padding()
                    }
                }
                VStack {
                    Text("RESET")
                    Button(action: {
                        gridHeight = 25
                        gridWidth = 25
                    }) {
                        Image(systemName: "gobackward")
                            .padding()
                    }
                    Button(action: {
                        gridHeight = 25
                        gridWidth = 25
                    }) {
                        Image(systemName: "gobackward")
                            .foregroundColor(.clear)
                            .padding()
                    }
                }
                
            }
            
        }
    }
}

