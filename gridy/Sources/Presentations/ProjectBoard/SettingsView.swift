//
//  SettingsView.swift
//  gridy
//
//  Created by xnoag on 11/5/23.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<ProjectBoard>
    @FocusState var textFieldFocus: Bool
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            VStack(alignment: .center, spacing: 16) {
                profileImage
                nameForm
                jobForm.padding(.bottom, 16)
                exit
            }
            .padding(16)
            .background(.white)
            .frame(width: 500, height: 250)
        }
    }
}

extension SettingsView {
    var profileImage: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Image("gridy-logo")
                .resizable()
                .frame(width: 96, height: 96)
                .overlay(alignment: .bottom) {
                    if viewStore.hoveredItem == .profileEditButton {
                        Text("편집")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.blackWhite)
                            .padding(.bottom, 6)
                            .background(
                                Rectangle()
                                    .foregroundStyle(.black)
                                    .frame(width: 96, height: 30)
                                    .blur(radius: 12)
                            )
                    }
                }
                .clipShape(Circle())
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .profileEditButton : ""))
                }
        }
    }
}

extension SettingsView {
    var nameForm: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var textFieldSubmit: Binding<Bool> {
                Binding(
                    get: { viewStore.textFieldSubmit },
                    set: { newValue in
                        viewStore.send(.textFieldSubmit(bool: newValue))
                    }
                )
            }
            HStack(alignment: .center, spacing: 0) {
                Text("Name")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.title)
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(viewStore.hoveredItem == .profileTextFieldEditButton ? Color.itemHovered : Color.item)
                    .foregroundStyle(viewStore.hoveredItem == .profileTextFieldEditButton ? Color.item : .clear)
                    .frame(width: 160, height: 24)
                    .overlay(alignment: .leading) {
                        if viewStore.textFieldSubmit {
                            Text(viewStore.profileName)
                                .font(.title3)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.title)
                                .padding(.leading, 8)
                        } else {
                            TextField(
                                viewStore.profileName,
                                text: viewStore.binding(
                                    get: \.profileName,
                                    send: { .profileNameChanged($0) }
                                )
                            )
                            .onSubmit {
                                viewStore.send(.textFieldSubmit(bool: true))
                            }
                            .focused($textFieldFocus)
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.title)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)
                        }
                    }
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .profileTextFieldEditButton : ""))
                    }
                    .onTapGesture {
                        viewStore.send(.textFieldSubmit(bool: false))
                        textFieldFocus = true
                    }
            }
        }
    }
}

extension SettingsView {
    var jobForm: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 0) {
                Text("Job")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.title)
                Spacer()
                Picker("", 
                       selection: viewStore.binding(
                        get: \.selectionOption,
                        send: { .changeOption($0)}
                       )) {
                           ForEach(0..<viewStore.jobOptions.count, id: \.self) {
                               Text(viewStore.jobOptions[$0])
                                   .font(.body)
                                   .fontWeight(.regular)
                                   .foregroundStyle(Color.title)
                           }
                       }
                       .frame(width: 168)
            }
        }
    }
}

extension SettingsView {
    var exit: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    // TODO: - 탈퇴 Button
                } label: {
                    Text("탈퇴하기")
                        .font(.title3)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.title)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(viewStore.hoveredItem == .exitButton ? Color.itemHovered : Color.item)
                                .frame(width: 64, height: 24)
                        )
                }
                .buttonStyle(.link)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .exitButton : ""))
                }
                Spacer()
            }
        }
    }
}
