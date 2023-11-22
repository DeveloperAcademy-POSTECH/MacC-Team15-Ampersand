//
//  ShareImageView.swift
//  gridy
//
//  Created by xnoag on 11/1/23.
//

import SwiftUI
import AppKit
import ComposableArchitecture

struct ShareImageView: View {
    let store: StoreOf<PlanBoard>
    let selfView: PlanBoardView
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isStartDatePickerPresented: Binding<Bool> {
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
            var isEndDatePickerPresented: Binding<Bool> {
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
            VStack(spacing: 16) {
                // Thumnail
                RoundedRectangle(cornerRadius: 8)
                    .overlay {
                        if let rederedNSImage = getRenderedImage() {
                            Image(nsImage: rederedNSImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Text("미리보기 실패")
                                .foregroundStyle(Color.subtitle)
                        }
                    }
                    .foregroundStyle(Color.item)
                    .frame(width: 436, height: 330)
                
                RoundedRectangle(cornerRadius: 8)
                    .overlay {
                        VStack(alignment: .leading) {
                            HStack(spacing: 8) {
                                RadioButton(isSelected: viewStore.selectFullPeriod)
                                    .onTapGesture {
                                        viewStore.send(.periodSelectionChanged(selectedFullPeriod: true))
                                    }
                                    .padding(.leading, 16)
                                Text("기간 모두")
                                    .foregroundStyle(Color.title)
                            }
                            HStack {
                                RadioButton(isSelected: !viewStore.selectFullPeriod)
                                    .onTapGesture {
                                        viewStore.send(.periodSelectionChanged(selectedFullPeriod: false))
                                    }
                                    .padding(.leading, 16)
                                Text("기간 설정")
                                    .foregroundStyle(Color.title)
                                Spacer()
                                    .frame(width: 16)
                                // Start Date
                                Button {
                                    viewStore.send(.popoverPresent(
                                        button: .startDatePickerButton,
                                        bool: true
                                    ))
                                } label: {
                                    Text("시작 : \(viewStore.selectedStartDate.formattedDate)")
                                        .foregroundStyle(Color.title)
                                        .frame(width: 132, height: 32)
                                        .background(viewStore.hoveredItem == .startDateHoveredButton ? Color.itemHovered : Color.clear)
                                        .cornerRadius(5)
                                        .onHover { isHovered in
                                            viewStore.send(.hoveredItem(name: isHovered ? .startDateHoveredButton : ""))
                                        }
                                }
                                .buttonStyle(.link)
                                .background(Color.clear)
                                .disabled(viewStore.selectFullPeriod)
                                .popover(isPresented: isStartDatePickerPresented) {
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
                                    }
                                    .padding()
                                }
                                Spacer()
                                    .frame(width: 8)
                                // End Date
                                Button {
                                    viewStore.send(.popoverPresent(
                                        button: .endDatePickerButton,
                                        bool: true
                                    ))
                                } label: {
                                    Text("종료 : \(viewStore.selectedEndDate.formattedDate)")
                                        .foregroundStyle(Color.title)
                                        .frame(width: 132, height: 32)
                                        .background(viewStore.hoveredItem == .endDateHoveredButton ? Color.itemHovered : Color.clear)
                                        .cornerRadius(5)
                                        .onHover { isHovered in
                                            viewStore.send(.hoveredItem(name: isHovered ? .endDateHoveredButton : ""))
                                        }
                                }
                                .buttonStyle(.link)
                                .background(Color.clear)
                                .disabled(viewStore.selectFullPeriod)
                                .popover(isPresented: isEndDatePickerPresented) {
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
                                    }
                                    .padding()
                                }
                                Spacer()
                            }
                        }
                    }
                    .foregroundStyle(Color.item)
                    .frame(width: 436, height: 88)
                
                systemBorder(.horizontal)
                    .padding(.horizontal, 16)
                
                HStack {
                    // Share
                    Button {
                        shareImage()
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(viewStore.hoveredItem == .shareButton ? Color.itemHovered : Color.item)
                            .frame(width: 80, height: 24)
                            .overlay(
                                Text("Share")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.button)
                            )
                    }
                    .buttonStyle(.link)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .shareButton : ""))
                    }
                    Spacer()
                    // Cancel
                    Button {
                        viewStore.send(.popoverPresent(
                            button: .shareImageButton,
                            bool: false
                        ))
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(viewStore.hoveredItem == .cancelButton ? Color.itemHovered : Color.item)
                            .frame(width: 80, height: 24)
                            .overlay(
                                Text("Cancel")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.button)
                            )
                    }
                    .buttonStyle(.link)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .cancelButton : ""))
                    }
                    // Save
                    Button {
                        saveImage()
                    } label: {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(viewStore.hoveredItem == .saveButton ? Color.itemHovered : Color.item)
                            .frame(width: 80, height: 24)
                            .overlay(
                                Text("Save")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.button)
                            )
                    }
                    .buttonStyle(.link)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .saveButton : ""))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(width: 468, height: 523)
        .padding(16)
        .background(Color.gray.opacity(0.3))
    }
    
    @MainActor private func getRenderedImage() -> NSImage? {
        return ImageRenderer(
            content: selfView
                .frame(width: 1411, height: 934)
                .environment(\.colorScheme, .dark)
        ).nsImage
    }
    
    @MainActor private func shareImage() {
        if let contentView = NSApp.keyWindow?.contentView {
            if let image = getRenderedImage() {
                let sharingServicePicker = NSSharingServicePicker(items: [image])
                sharingServicePicker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
            }
        }
    }
    
    @MainActor private func saveImage() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "저장하기"
        savePanel.message = "저장할 위치와 파일의 이름을 지정하세요"
        savePanel.begin { response in
            if response == .OK,
               let url = savePanel.url {
                if let image = getRenderedImage() {
                    self.savePNG(image: image, url: url)
                } else {
                    print("‼️ 플랜보드의 이미지 생성에 실패했습니다 ‼️")
                }
            }
        }
    }
    
    private func savePNG(image: NSImage, url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else { return }
        do {
            try pngData.write(to: url)
        } catch {
            print("=== Error saving image: \(error.localizedDescription) ❌")
        }
    }
}

/// radio button custom
struct RadioButton: View {
    let isSelected: Bool
    
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
