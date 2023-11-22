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
        VStack(spacing: 24) {
            thumbnail
            selectPeriodArea
            
            HStack(spacing: 12) {
                cancelButton
                shareButton
                Spacer()
                exportButton
            }
        }
        .padding(16)
        .frame(width: 468, height: 524)
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

@MainActor
extension ShareImageView {
    var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.item)
            if let rederedNSImage = getRenderedImage() {
                Image(nsImage: rederedNSImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("미리보기 실패")
                    .foregroundStyle(Color.subtitle)
            }
        }
    }
}

extension ShareImageView {
    var selectPeriodArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.item)
                Picker(
                    "",
                    selection: viewStore.binding(
                        get: \.selectPeriodTag,
                        send: { .periodSelectionChanged(selectedTag: $0) }
                    )
                ) {
                    Text("현재 화면")
                        .foregroundStyle(Color.title)
                        .tag(1)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 12)
                    HStack {
                        Text("기간 설정")
                            .foregroundStyle(Color.title)
                        
                        HStack {
                            selectStartDatePicker
                            selectEndDatePicker
                        }
                        .opacity(viewStore.selectPeriodTag == 1 ? 0 : 1)
                    }
                    .padding(.horizontal, 4)
                    .tag(2)
                }
                .pickerStyle(.radioGroup)
            }
            .frame(height: 92)
        }
    }
    
    var selectStartDatePicker: some View {
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
            Text("시작")
                .foregroundStyle(Color.title)
                .padding(.leading, 24)
                .padding(.trailing, 8)
            Button {
                viewStore.send(.popoverPresent(
                    button: .startDatePickerButton,
                    bool: true
                ))
            } label: {
                Text(viewStore.selectedStartDate.formattedDate)
                    .foregroundStyle(Color.title)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.itemHovered)
                    .cornerRadius(6)
            }
            .buttonStyle(.link)
            .background(Color.clear)
            .popover(isPresented: isStartDatePickerPresented) {
                DatePicker(
                    "",
                    selection: viewStore.binding(
                        get: \.selectedStartDate,
                        send: { .selectedStartDateChanged($0) }),
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding(4)
            }
        }
    }
    
    var selectEndDatePicker: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
            Text("종료")
                .foregroundStyle(Color.title)
                .padding(.leading, 24)
                .padding(.trailing, 8)
            Button {
                viewStore.send(.popoverPresent(
                    button: .endDatePickerButton,
                    bool: true
                ))
            } label: {
                Text(viewStore.selectedEndDate.formattedDate)
                    .foregroundStyle(Color.title)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.itemHovered)
                    .cornerRadius(6)
            }
            .buttonStyle(.link)
            .background(Color.clear)
            .popover(isPresented: isEndDatePickerPresented) {
                DatePicker(
                    "",
                    selection: viewStore.binding(
                        get: \.selectedEndDate,
                        send: { .selectedEndDateChanged($0) }),
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding(4)
            }
        }
    }
}

@MainActor
extension ShareImageView {
    var cancelButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.popoverPresent(
                    button: .shareImageButton,
                    bool: false
                ))
            } label: {
                Text("Cancel")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.button)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(viewStore.hoveredItem == .cancelButton ? Color.itemHovered : Color.item)
                    )
            }
            .buttonStyle(.link)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .cancelButton : ""))
            }
        }
    }
    
    var shareButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                shareImage()
            } label: {
                Text("Share")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.button)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(viewStore.hoveredItem == .shareButton ? Color.itemHovered : Color.item)
                    )
            }
            .buttonStyle(.link)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .shareButton : ""))
            }
        }
    }
    
    var exportButton: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                saveImage()
            } label: {
                Text("Export to Image")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.button)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.accentColor)
                    )
            }
            .buttonStyle(.link)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .saveButton : ""))
            }
        }
    }
}
