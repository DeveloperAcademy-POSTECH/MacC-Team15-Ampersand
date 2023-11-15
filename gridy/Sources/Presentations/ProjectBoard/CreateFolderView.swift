//
//  CreateFolderView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import ComposableArchitecture

struct CreateFolderView: View {
    let store: StoreOf<ProjectBoard>
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            folderNameTextField
            HStack(alignment: .center, spacing: 8) {
                cancel
                create
            }
        }
        .padding(24)
        .frame(width: 480, height: 160)
    }
}

extension CreateFolderView {
    var folderNameTextField: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.item)
                .frame(height: 48)
                .overlay(
                    TextField(
                        "Folder Name",
                        text: viewStore.binding(
                            get: \.folderName,
                            send: { .folderTitleChanged($0) }
                        )
                    )
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                )
        }
    }
}

extension CreateFolderView {
    var cancel: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                // TODO: - Cancel Button
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

extension CreateFolderView {
    var create: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.popoverPresent(
                    button: .createPlanBoardButton,
                    bool: false
                ))
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == "createButton" ? Color.buttonHovered : .button)
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
                viewStore.send(.hoveredItem(name: isHovered ? "createButton" : ""))
            }
        }
    }
}
