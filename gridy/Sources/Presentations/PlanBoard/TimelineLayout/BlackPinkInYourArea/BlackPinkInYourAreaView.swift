//
//  BlackPinkInYourAreaView.swift
//  gridy
//
//  Created by xnoag on 2023/09/27.
//

import SwiftUI

struct BlackPinkInYourAreaView: View {
    var body: some View {
        ZStack {
        Rectangle()
            .foregroundStyle(.white)
            .border(.black)
            Text("BlackPinkInYourArea")
        }
    }
}

struct BlackPinkInYourAreaView_Previews: PreviewProvider {
    static var previews: some View {
        BlackPinkInYourAreaView()
    }
}
