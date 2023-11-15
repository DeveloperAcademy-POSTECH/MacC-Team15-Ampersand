//
//  CreateBoardView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct CreatePlanBoardView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            VStack(alignment: .center, spacing: 24) {
                planBoardNameTextField
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
}

extension CreatePlanBoardView {
    var planBoardNameTextField: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.item)
                .frame(height: 48)
                .overlay(
                    TextField("Project Name",
                              text: viewStore.binding(
                                get: \.title,
                                send: { .titleChanged($0) }
                              ))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .onSubmit {
                        if !viewStore.title.isEmpty {
                            viewStore.send(.createNewProjectButtonTapped)
                            viewStore.send(.popoverPresent(
                                button: .createPlanBoardButton,
                                bool: false
                            ))
                        }
                    }
                )
        }
    }
}

extension CreatePlanBoardView {
    var startDuration: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var startDatePickerPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.startDatePickerPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .startDatePickerButton,
                            bool: newValue
                        ))
                    }
                )
            }
            Button {
                viewStore.send(.popoverPresent(
                    button: .startDatePickerButton,
                    bool: true
                ))
            } label: {
                Text("시작 : \(viewStore.selectedStartDate.formattedDate)")
                    .foregroundStyle(Color.title)
                    .frame(width: 132, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(viewStore.hoveredItem == .startDateHoveredButton ? Color.itemHovered : .clear)
                    )
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .startDateHoveredButton : ""))
                    }
            }
            .buttonStyle(.link)
            .popover(isPresented: startDatePickerPresented) {
                VStack {
                    DatePicker(
                        "",
                        selection: viewStore.binding(
                            get: \.selectedStartDate,
                            send: { .selectedStartDateChanged($0) }),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    Button("Done") {
                        viewStore.send(.popoverPresent(
                            button: .startDatePickerButton,
                            bool: false
                        ))
                    }
                }
                .padding()
            }
        }
    }
}

extension CreatePlanBoardView {
    var endDuration: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var endDatePickerPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.endDatePickerPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .endDatePickerButton,
                            bool: newValue
                        ))
                    }
                )
            }
            Button {
                viewStore.send(.popoverPresent(
                    button: .endDatePickerButton,
                    bool: true
                ))
            } label: {
                Text("종료 : \(viewStore.selectedEndDate.formattedDate)")
                    .foregroundStyle(Color.title)
                    .frame(width: 132, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(viewStore.hoveredItem == .endDateHoveredButton ? Color.itemHovered : .clear)
                    )
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .endDateHoveredButton : ""))
                    }
            }
            .buttonStyle(.link)
            .popover(isPresented: endDatePickerPresented) {
                VStack {
                    DatePicker(
                        "",
                        selection: viewStore.binding(
                            get: \.selectedEndDate,
                            send: { .selectedEndDateChanged($0) }),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    Button("Done") {
                        viewStore.send(.popoverPresent(
                            button: .endDatePickerButton,
                            bool: false
                        ))
                    }
                }
                .padding()
            }
        }
    }
}

extension CreatePlanBoardView {
    var cancel: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.popoverPresent(
                    button: .createPlanBoardButton,
                    bool: false
                ))
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == .cancelButton ? Color.buttonHovered : .button)
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
                viewStore.send(.hoveredItem(name: isHovered ? .cancelButton : ""))
            }
        }
    }
}

extension CreatePlanBoardView {
    var create: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                if !viewStore.title.isEmpty {
                    viewStore.send(.createNewProjectButtonTapped)
                    viewStore.send(.popoverPresent(
                        button: .createPlanBoardButton,
                        bool: false
                    ))
                }
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == .createButton ? Color.buttonHovered : .button)
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
                viewStore.send(.hoveredItem(name: isHovered ? .createButton : ""))
            }
            .disabled(viewStore.title.isEmpty)
        }
    }
}
