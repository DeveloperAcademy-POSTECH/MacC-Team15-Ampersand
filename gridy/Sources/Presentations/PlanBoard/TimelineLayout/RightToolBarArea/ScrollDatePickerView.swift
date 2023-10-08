//
//  ScrollDatePickerView.swift
//  gridy
//
//  Created by SY AN on 10/7/23.
//

import SwiftUI

struct ScrollDatePickerView: View {
    @State private var selectedDate = Date()
    var body: some View {
        VStack {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            Text("선택날짜: \(selectedDate, formatter: dateFormatter)")
                            .padding()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("이동")
            })
        }
    }
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }
}

#Preview {
    ScrollDatePickerView()
}
