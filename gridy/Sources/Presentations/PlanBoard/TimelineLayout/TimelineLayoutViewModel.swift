//
//  TimelineLayoutViewModel.swift
//  gridy
//
//  Created by 최민규 on 10/17/23.
//

import SwiftUI

class TimelineLayoutViewModel: ObservableObject {
    
    /// ScheduleArea의 Row 갯수로, 나중에는 View의 크기에 따라 max갯수를 계산시키는 로직으로 변경되면서 maxScheduleAreaRow라는 변수가 될 예정입니다.
    @Published var numOfScheduleAreaRow = 5
    
    /// 그리드 Path의 두께를 결정합니다. Line Area, ScheduleArea에서 따르고 있으며, ListArea는 별도의 Stroke를 가질 것으로 생각됩니다.
    @Published var columnStroke = CGFloat(0.1)
    @Published var rowStroke = CGFloat(0.5)
    
    /// 그리드의 사이즈에 대한 변수들입니다. RightToolBarArea에서 변수를 조정할 수 있습니다. Magnificationn과 min/maxSIze는 사용자가 확대했을 때 최대 최소 크기를 지정하기 위해 필요한 제한 값입니다.
    let minGridSize = CGFloat(20)
    let maxGridSize = CGFloat(70)
    @Published var gridWidth = CGFloat(45)
    @Published var scheduleAreaGridHeight = CGFloat(45)
    @Published var lineAreaGridHeight = CGFloat(45)
    @Published var horizontalMagnification = CGFloat(1.0)
    @Published var verticalMagnification = CGFloat(1.0)
    
    /// LineArea의 local 영역에서 마우스가 호버링 된 위치의 셀정보를 담습니다. 아직은 RightToolBarArea에서 확인용으로만 사용하고 있습니다.
    @Published var hoverLocation: CGPoint = .zero
    @Published var hoveringCellRow = 0
    @Published var hoveringCellCol = 0
    @Published var isHovering = false
    
    /// 선택된 영역을 배열로 담습니다. selectedDateRange는 Plan생성 API가 들어오면 삭제될 변수입니다.
    @Published var selectedGridRanges: [SelectedGridRange] = []
    @Published var selectedDateRanges: [SelectedDateRange] = []
    
    /// 뷰의 GeometryReader값의 변화에 따라 Max 그리드 갯수가 변호합니다.
    @Published var maxLineAreaRow = 0
    @Published var maxCol = 0
    
    /// 뷰가 움직인 크기를 나타내는 변수입니다.
    @Published var shiftedRow = 0
    @Published var shiftedCol = 0
    
    /// 마우스로 드래그 할 때 화면 밖으로 벗어난 치수를 담고있는 변수입니다만, 현재 shiftedRow/Col과 역할이 비슷하여 하나로 합치는 것을 고려 중입니다.
    @Published var exceededRow = 0
    @Published var exceededCol = 0
    
    /// NSEvent로 받아온 Shift와 Command 눌린 상태값입니다.
    @Published var isShiftKeyPressed = false
    @Published var isCommandKeyPressed = false

    func shiftSelectedCell(rowOffset: Int, colOffset: Int) {
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
            if Int(selectedGridRanges.last!.end.col) < shiftedCol ||
                Int(selectedGridRanges.last!.end.col) > maxCol + shiftedCol - 2 {
                shiftedCol += colOffset
            }
            /// 선택영역 중 마지막 영역의  끝지점 Row이 현재 뷰의 영점인 shiftedRow보다 작거나, 현재 뷰의 최대점인  maxRow + shiftedRow - 2 을 넘어갈 떄 화면이 스크롤된다.
            if Int(selectedGridRanges.last!.end.row) < shiftedRow ||
                Int(selectedGridRanges.last!.end.row) > maxLineAreaRow + shiftedRow - 2 {
                shiftedRow = max(shiftedRow + rowOffset, 0)
            }
        }
    }
    
    func shiftToToday() {
        shiftedCol = 0
        if let lastSelected = selectedGridRanges.last {
            selectedGridRanges = [SelectedGridRange(start: (lastSelected.start.row, 0), end: (lastSelected.start.row, 0))]
        }
    }
    
    // TODO: esc 눌렀을 때 row가 보정되지 않는 로직을 수정
    func escapeSelectedCell() {
        /// esc를 눌렀을 때 마지막 선택영역의 시작점이 선택된다.
        if let lastSelected = selectedGridRanges.last {
            selectedGridRanges = [SelectedGridRange(start: (lastSelected.start.row, lastSelected.start.col), end: (lastSelected.start.row, lastSelected.start.col))]
        }
        /// 만약 위 영역이 화면을 벗어났다면 화면을 스크롤 시킨다.
        if Int(selectedGridRanges.last!.start.col) < shiftedCol ||
            Int(selectedGridRanges.last!.start.col) > maxCol + shiftedCol - 2 {
            shiftedCol = selectedGridRanges.last!.start.col - 2
        }
        if Int(selectedGridRanges.last!.start.row) < shiftedRow ||
            Int(selectedGridRanges.last!.start.row) > maxLineAreaRow + shiftedRow - 2 {
            shiftedRow = max(selectedGridRanges.last!.start.row, 0)
        }
    }
}

