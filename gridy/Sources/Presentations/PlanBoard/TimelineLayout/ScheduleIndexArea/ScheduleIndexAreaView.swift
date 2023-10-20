//
//  ScheduleIndexAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct ScheduleIndexAreaView: View {
    var body: some View {
        // TODO: ScheduleIndexArea (하위코드삭제)
        ZStack {
            Rectangle()
                .foregroundStyle(.white)
                .border(.black)
            Text("ShceduleIndexArea")
                .frame(width: 35, height: 140)
        }
    }
}

struct ScheduleIndexAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleIndexAreaView()
    }
}
