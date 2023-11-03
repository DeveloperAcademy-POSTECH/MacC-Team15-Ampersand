//
//  ScrollSampleView.swift
//  gridy
//
//  Created by Jin Sang woo on 11/4/23.
//


import SwiftUI

class TwoFingerSwipeView: NSView {
    var onSwipeChange: ((CGPoint) -> Void)?
    var onSwipeEnd: (() -> Void)?
    
    override func scrollWheel(with event: NSEvent) {
        guard event.phase == .changed || event.momentumPhase == .began || event.momentumPhase == .changed else {
            onSwipeEnd?()
            return
        }
        
        let scrollingDeltaX = event.scrollingDeltaX
        let scrollingDeltaY = event.scrollingDeltaY
        
        onSwipeChange?(CGPoint(x: scrollingDeltaX, y: scrollingDeltaY))
    }
}

struct TwoFingerSwipeViewRepresentable: NSViewRepresentable {
    var onSwipeChange: (CGPoint) -> Void
    var onSwipeEnd: () -> Void
    
    func makeNSView(context: Context) -> TwoFingerSwipeView {
        let view = TwoFingerSwipeView()
        view.onSwipeChange = onSwipeChange
        view.onSwipeEnd = onSwipeEnd
        return view
    }
    
    func updateNSView(_ nsView: TwoFingerSwipeView, context: Context) {}
}

struct ScrollSampleView: View {
    @State private var circlePosition = CGPoint(x: 150, y: 100) /// 원의 초기 위치
    @State private var pathPoints: [CGPoint] = [] /// 이동 경로를 저장할 배열
    @State private var swipeDelta = CGPoint(x: 0, y: 0) /// 스와이프 변화량
    
    func handleSwipeChange(delta: CGPoint) {
        let magnitude = sqrt(delta.x * delta.x + delta.y * delta.y)
        let directionX = magnitude > 0 ? delta.x / magnitude : 0
        let directionY = magnitude > 0 ? delta.y / magnitude : 0
        
        /// 이동량을 단위 벡터로 만들어서 1의 거리만큼 이동
        swipeDelta = CGPoint(x: directionX, y: directionY)
        
        circlePosition = CGPoint(
            x: circlePosition.x + swipeDelta.x,
            y: circlePosition.y + swipeDelta.y
        )
        pathPoints.append(circlePosition)
    }
    
    func handleSwipeEnd() {
        /// 스와이프가 끝났을 때 액션
        withAnimation() {
            pathPoints.removeAll()
            swipeDelta = CGPoint(x: 0, y: 0) /// 스와이프 변화량을 리셋
        }
    }
    
    var body: some View {
        VStack {
            TwoFingerSwipeViewRepresentable(onSwipeChange: handleSwipeChange, onSwipeEnd: handleSwipeEnd)
                .frame(width: 300, height: 200)
                .border(Color.black, width: 2)
                .background(
                    Path { path in
                        for (index, point) in pathPoints.enumerated() {
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                    }
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                )
            Text("Swipe Delta: (\(Int(swipeDelta.x)), \(Int(swipeDelta.y)))")
            
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .position(circlePosition)
        }
    }
}
