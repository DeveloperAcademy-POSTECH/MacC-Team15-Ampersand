//
//  ScrollDatePickerView.swift
//  gridy
//
//  Created by SY AN on 10/7/23.
//

import SwiftUI

struct ScrollDatePickerView: View {
    @State private var selectedDate = Date()
    @Binding var proxy: ScrollViewProxy?
    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            
            Button(action: {
                withAnimation {
                    let scrollIndex = selectedDate.integerDate
                    proxy?.scrollTo(scrollIndex, anchor: .leading)
                }
            }, label: {
                Text("이동")
            })
        }
    }
}
