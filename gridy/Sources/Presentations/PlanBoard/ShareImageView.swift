//
//  ShareImageView.swift
//  gridy
//
//  Created by Royce on 11/1/23.
//

import SwiftUI

struct ShareImageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allPeriodsChecked = false
    @State private var startDateChecked = false
    @State private var cancelHovered = false
    @State private var isStartDateHovered = false
    @State private var isEndDateHovered = false
    
    var body: some View {
        VStack(spacing : 16){
            RoundedRectangle(cornerRadius: 8)
                .overlay(
                    Text("Thumbnail")
                        .foregroundStyle(Color.subtitle) /// Color #747474로 바꿔야함
                )
                .foregroundStyle(Color.item)
                .frame(width:436, height:330)
            RoundedRectangle(cornerRadius: 8)
                .overlay(){
                    VStack(alignment:.leading) {
                        HStack(spacing : 8) {
                            RadioButton(isSelected: $allPeriodsChecked)
                                .padding(.leading, 16)
                            Text("기간 모두")
                                .foregroundColor(Color.title)
                        }
                        HStack() {
                            RadioButton(isSelected: $startDateChecked)
                                .padding(.leading, 16)
                            Text("기간 설정")
                                .foregroundColor(Color.title)
                            Spacer()
                                .frame(width:16)
                            
                            Text("시작 : 2023.10.05.")
                                .foregroundColor(Color.title)
                                .frame(width: 132, height: 32)
                                .background(isStartDateHovered ? Color.itemHovered : Color.clear)
                                .cornerRadius(5)
                                .onHover { hover in
                                    isStartDateHovered = hover
                                }
                            Spacer()
                                .frame(width:8)

                            Text("종료 : 2023.11.25.")
                                .foregroundColor(Color.title)
                                .frame(width: 132, height: 32)
                                .background(isEndDateHovered ? Color.itemHovered : Color.clear)
                                .cornerRadius(5)
                                .onHover { hover in
                                    isEndDateHovered = hover
                                }
                            Spacer()
                        }
                    }
                }
                .foregroundStyle(Color.item)
                .frame(width:436, height:88)
            
            borderSpacer(.horizontal)
                .padding(.horizontal, 16)

            HStack(){
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Share")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.button)
                        )
                }
                .buttonStyle(.link)
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
                        .foregroundStyle(Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Create")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.button)
                        )
                }
                .buttonStyle(.link)
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 468, height: 523)
        .padding(16)
        .background(Color.gray.opacity(0.3))
        
    }
}

/// radio button custom
struct RadioButton: View {
    @Binding var isSelected: Bool
    
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
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

#Preview {
    ShareImageView()
}
