//
//  TimelineLayoutViewModel.swift
//  gridy
//
//  Created by 최민규 on 10/17/23.
//

import SwiftUI

class TimelineLayoutViewModel: ObservableObject {
    @Published var numOfScheduleAreaRow = 5
    @Published var numOfCol = 30
    
    let minGridSize = CGFloat(20)
    let maxGridSize = CGFloat(70)
    @Published var gridWidth = CGFloat(45)
    @Published var scheduleAreaGridHeight = CGFloat(45)
    @Published var lineAreaGridHeight = CGFloat(45)
    @Published var horizontalMagnification = CGFloat(1.0)
    @Published var verticalMagnification = CGFloat(1.0)
    
    @Published var hoverLocation: CGPoint = .zero
    @Published var hoveringCellRow = 0
    @Published var hoveringCellCol = 0
    @Published var isHovering = false
    
    @Published var selectedGridRanges: [SelectedGridRange] = []
    @Published var selectedDateRanges: [SelectedDateRange] = []
    
    @Published var maxLineAreaRow = 0
    @Published var maxCol = 0
    @Published var exceededRow = 0
    @Published var exceededCol = 0
    
    @Published var isShiftKeyPressed = false
    @Published var isCommandKeyPressed = false
    
    @Published var columnStroke = CGFloat(0.1)
    @Published var rowStroke = CGFloat(0.5)
    
    func moveSelectedCell(rowOffset: Int, colOffset: Int) {
        if !selectedGridRanges.isEmpty {
            if !isShiftKeyPressed {
                /// 넓은 범위를 선택한 상태에서 방향키를 눌렀을 때, 시작점의 위치 - 2로 화면이 이동하는 기능
                if selectedGridRanges.last!.start.col != selectedGridRanges.last!.end.col {
                    if selectedGridRanges.last!.start.col < exceededCol {
                        exceededCol = selectedGridRanges.last!.start.col - 2
                    } else if selectedGridRanges.last!.start.col > exceededCol + maxCol + 2 {
                        exceededCol = selectedGridRanges.last!.start.col - 2
                    }
                }
                /// 선택영역 중 마지막 영역의 시작지점과 끝 지점 모두 colOffset, rowOffset만큼 이동한다. Command가 눌리지 않았기 때문에 selectedRanges는 1개의 크기만을 가진다.
                let movedRow = Int(selectedGridRanges.last!.start.row) + rowOffset
                let movedCol = Int(selectedGridRanges.last!.start.col) + colOffset
                selectedGridRanges = [SelectedGridRange(start: (movedRow, movedCol), end: (movedRow, movedCol))]
            } else {
                /// Shift를 누른 상태에서는 선택영역 중 마지막 영역의 끝 지점만 모두 colOffset, rowOffset만큼 이동한다. Command가 눌리지 않았기 때문에 selectedRanges는 1개의 크기만을 가진다.
                let startRow = Int(selectedGridRanges.last!.start.row)
                let startCol = Int(selectedGridRanges.last!.start.col)
                let movedEndRow = Int(selectedGridRanges.last!.end.row) + rowOffset
                let movedEndCol = Int(selectedGridRanges.last!.end.col) + colOffset
                selectedGridRanges = [SelectedGridRange(start: (startRow, startCol), end: (movedEndRow, movedEndCol))]
            }
            /// 선택영역 중 마지막 영역의  끝지점 Col이 현재 뷰의 영점인 exceededCol보다 작거나, 현재 뷰의 최대점인  maxCol + exceededCol - 2 을 넘어갈 떄 화면이 스크롤된다.
            if Int(selectedGridRanges.last!.end.col)  < exceededCol ||
                Int(selectedGridRanges.last!.end.col) > maxCol + exceededCol - 2 {
                exceededCol += colOffset
                print(maxCol)
            }
            /// 선택영역 중 마지막 영역의  끝지점 Row이 현재 뷰의 영점인 exceededRow보다 작거나, 현재 뷰의 최대점인  maxRow + exceededRow - 2 을 넘어갈 떄 화면이 스크롤된다.
            if Int(selectedGridRanges.last!.end.row) < exceededRow ||
                Int(selectedGridRanges.last!.end.row) > maxLineAreaRow + exceededRow - 2 {
                exceededRow = max(exceededRow + rowOffset, 0)
            }
        }
    }
}

