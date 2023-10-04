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
        ScrollView([.vertical, .horizontal]) {
            HStack {
                ForEach(1..<100) { _ in
                    VStack {
                        ForEach(1..<10) { _ in
                            Rectangle()
                                .frame(width: 25, height: 25)
                        }
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
