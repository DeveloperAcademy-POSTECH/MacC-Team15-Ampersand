//
//  ScheduleAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ScheduleAreaView: View {
    var body: some View {
        // TODO: ScheduleArea (하위코드삭제)
        HStack(spacing: 0) {
            ForEach(1..<70) { _ in
                VStack(spacing: 0) {
                    ForEach(1..<6) { _ in
                        Rectangle()
                            .border(.green)
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
    }
}

struct ScheduleAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleAreaView()
    }
}
