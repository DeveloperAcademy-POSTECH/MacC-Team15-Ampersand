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
    
    @Published var columnStroke = CGFloat(0.1)
    @Published var rowStroke = CGFloat(0.5)
    
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
    @Published var shiftedRow = 0
    @Published var shiftedCol = 0
    @Published var exceededRow = 0
    @Published var exceededCol = 0
    @Published var isShiftKeyPressed = false
    @Published var isCommandKeyPressed = false
    
    // TODO: geo 받아오기
    @Published var listColumnWidth: [[CGFloat]] = [[266], [132, 132], [24, 119, 119]]
    func moveSelectedCell(rowOffset: Int, colOffset: Int) {
        if !selectedGridRanges.isEmpty {
            if !isShiftKeyPressed {
                /// 넓은 범위를 선택한 상태에서 방향키를 눌렀을 때, 시작점의 위치 - 2로 화면이 이동하는 기능
                if selectedGridRanges.last!.start.col != selectedGridRanges.last!.end.col {
                    if selectedGridRanges.last!.start.col < shiftedCol {
                        shiftedCol = selectedGridRanges.last!.start.col - 2
                    } else if selectedGridRanges.last!.start.col > shiftedCol + maxCol + 2 {
                        shiftedCol = selectedGridRanges.last!.start.col - 2
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
            /// 선택영역 중 마지막 영역의  끝지점 Col이 현재 뷰의 영점인 shiftedCol보다 작거나, 현재 뷰의 최대점인  maxCol + shiftedCol - 2 을 넘어갈 떄 화면이 스크롤된다.
            if Int(selectedGridRanges.last!.end.col)  < shiftedCol ||
                Int(selectedGridRanges.last!.end.col) > maxCol + shiftedCol - 2 {
                shiftedCol += colOffset
                print(maxCol)
            }
            /// 선택영역 중 마지막 영역의  끝지점 Row이 현재 뷰의 영점인 shiftedRow보다 작거나, 현재 뷰의 최대점인  maxRow + shiftedRow - 2 을 넘어갈 떄 화면이 스크롤된다.
            if Int(selectedGridRanges.last!.end.row) < shiftedRow ||
                Int(selectedGridRanges.last!.end.row) > maxLineAreaRow + shiftedRow - 2 {
                shiftedRow = max(shiftedRow + rowOffset, 0)
            }
        }
    }
}

