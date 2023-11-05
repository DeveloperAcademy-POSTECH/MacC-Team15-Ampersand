//
//  ShareImageView.swift
//  gridy
//
//  Created by Royce on 11/1/23.
//

import SwiftUI
import AppKit

enum PeriodSelection {
    case allPeriods
    case setPeriods
}
struct ShareImageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var periodSelection: PeriodSelection = .allPeriods
    
    @State private var shareHovered = false
    @State private var cancelHovered = false
    @State private var createHovered = false
    @State private var isStartDateHovered = false
    @State private var isEndDateHovered = false
    @State private var selectedStartDate = Date()
    @State private var isStartDatePickerPresented = false
    @State private var selectedEndDate = Date()
    @State private var isEndDatePickerPresented = false
    
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .overlay(
                    Text("Thumbnail")
                        .foregroundStyle(Color.subtitle) /// Color #747474로 바꿔야함
                )
                .foregroundStyle(Color.item)
                .frame(width: 436, height: 330)
            RoundedRectangle(cornerRadius: 8)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack(spacing: 8) {
                            RadioButton(isSelected: periodSelection == .allPeriods)
                                .onTapGesture {
                                    periodSelection = .allPeriods
                                }
                                .padding(.leading, 16)
                            Text("기간 모두")
                                .foregroundColor(Color.title)
                        }
                        HStack {
                            RadioButton(isSelected: periodSelection == .setPeriods)
                                .onTapGesture {
                                    periodSelection = .setPeriods
                                }
                                .padding(.leading, 16)
                            Text("기간 설정")
                                .foregroundColor(Color.title)
                            Spacer()
                                .frame(width: 16)
                            Button(action: {
                                isStartDatePickerPresented = true
                            }) {
                                Text("시작 : \(formattedDate(date: selectedStartDate))")
                                    .foregroundColor(Color.title)
                                    .frame(width: 132, height: 32)
                                    .background(isStartDateHovered ? Color.itemHovered : Color.clear)
                                    .cornerRadius(5)
                                    .onHover { hover in
                                        isStartDateHovered = hover
                                    }
                            }
                            .buttonStyle(.link)
                            .background(Color.clear)
                            .disabled(periodSelection == .allPeriods)
                            .popover(isPresented: $isStartDatePickerPresented) {
                                VStack {
                                    DatePicker("", selection: $selectedStartDate, displayedComponents: [.date])
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .labelsHidden()
                                    Button("Done", action: {
                                        isStartDatePickerPresented = false
                                    })
                                }
                                .padding()
                            }
                            Spacer()
                                .frame(width: 8)
                            Button(action: {
                                isEndDatePickerPresented = true
                            }) {
                                Text("종료 : \(formattedDate(date: selectedEndDate))")
                                    .foregroundColor(Color.title)
                                    .frame(width: 132, height: 32)
                                    .background(isEndDateHovered ? Color.itemHovered : Color.clear)
                                    .cornerRadius(5)
                                    .onHover { hover in
                                        isEndDateHovered = hover
                                    }
                            }
                            .buttonStyle(.link)
                            .background(Color.clear)
                            .disabled(periodSelection == .allPeriods)
                            .popover(isPresented: $isEndDatePickerPresented) {
                                VStack {
                                    DatePicker("", selection: $selectedEndDate, displayedComponents: [.date])
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .labelsHidden()
                                    Button("Done", action: {
                                        isEndDatePickerPresented = false
                                    })
                                }
                                .padding()
                            }
                            Spacer()
                        }
                    }
                }
                .foregroundStyle(Color.item)
                .frame(width: 436, height: 88)
            
            borderSpacer(.horizontal)
                .padding(.horizontal, 16)
            
            HStack {
                Button {
                    shareImage()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(shareHovered ? Color.itemHovered : Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Share")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.button)
                        )
                }
                .buttonStyle(.link)
                .onHover { hover in
                    shareHovered = hover
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(cancelHovered ? Color.itemHovered : Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Cancel")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.button)
                        )
                }
                .buttonStyle(.link)
                .onHover { hover in
                    cancelHovered = hover
                }
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(createHovered ? Color.itemHovered : Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Create")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.button)
                        )
                }
                .buttonStyle(.link)
                .onHover { hover in
                    createHovered = hover
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 468, height: 523)
        .padding(16)
        .background(Color.gray.opacity(0.3))
    }
    
    /// Appkit을 이용한 share image
    func shareImage() {
        let image = NSImage()
        let sharingServicePicker = NSSharingServicePicker(items: [image])
        sharingServicePicker.show(relativeTo: NSRect(), of: NSApp.keyWindow!.contentView!, preferredEdge: .minY)
    }
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        return formatter.string(from: date)
    }
}

/// radio button custom
struct RadioButton: View {
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
            
            if isSelected {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 14, height: 14)
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

#Preview {
    ShareImageView()
}
