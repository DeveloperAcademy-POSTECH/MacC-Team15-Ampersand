//
//  CreateBoardView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI

struct CreatePlanBoardView: View {
    @State var projectName = ""
    @State var cancelHover = false
    @State var createHover = false
    @State var startDateHovered = false
    @State var endDateHovered = false
    @State var selectedStartDate = Date()
    @State var selectedEndDate = Date()
    @State var startDatePickerPresented = false
    @State var endDatePickerPresented = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            folderNameTextField
            HStack(alignment: .center, spacing: 16) {
                startDuration
                endDuration
            }
            HStack(alignment: .center, spacing: 8) {
                cancel
                create
            }
        }
        .padding(24)
        .frame(width: 480)
    }
}

extension CreatePlanBoardView {
    var folderNameTextField: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.item)
            .frame(height: 48)
            .overlay(
                TextField("Project Name", text: $projectName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
            )
    }
}

extension CreatePlanBoardView {
    var startDuration: some View {
        Button {
            startDatePickerPresented = true
        } label: {
            Text("시작 : \(selectedStartDate.formattedDate)")
                .foregroundStyle(Color.title)
                .frame(width: 132, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(startDateHovered ? Color.itemHovered : Color.clear)
                )
                .onHover { hover in
                    startDateHovered = hover
                }
        }
        .buttonStyle(.link)
        .popover(isPresented: $startDatePickerPresented) {
            VStack {
                DatePicker("", selection: $selectedStartDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                Button("Done", action: {
                    startDatePickerPresented = false
                })
            }
            .padding()
        }
    }
}

extension CreatePlanBoardView {
    var endDuration: some View {
        Button {
            endDatePickerPresented = true
        } label: {
            Text("종료 : \(selectedEndDate.formattedDate)")
                .foregroundStyle(Color.title)
                .frame(width: 132, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(endDateHovered ? Color.itemHovered : Color.clear)
                )
                .onHover { hover in
                    endDateHovered = hover
                }
        }
        .buttonStyle(.link)
        .popover(isPresented: $endDatePickerPresented) {
            VStack {
                DatePicker("", selection: $selectedEndDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                Button("Done", action: {
                    endDatePickerPresented = false
                })
            }
            .padding()
        }
    }
}

extension CreatePlanBoardView {
    var cancel: some View {
        Button {
            // TODO: - Cancel Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(cancelHover ? Color.buttonHovered : Color.button)
                .frame(height: 32)
                .overlay(
                    Text("Cancel")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buttonText)
                )
        }
        .buttonStyle(.link)
        .onHover { isHovered in
            cancelHover = isHovered
        }
    }
}

extension CreatePlanBoardView {
    var create: some View {
        Button {
            // TODO: - Create Button
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(createHover ? Color.buttonHovered : Color.button)
                .frame(height: 32)
                .overlay(
                    Text("Create")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buttonText)
                )
        }
        .buttonStyle(.link)
        .onHover { isHovered in
            createHover = isHovered
        }
    }
}

#Preview {
    CreatePlanBoardView()
}
