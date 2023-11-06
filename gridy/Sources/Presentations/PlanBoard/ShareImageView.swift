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
/// 한 struct 안에 코드가 너무 길어서 function을 빼려고 했는데 일단은 여기 다 넣어놓겠습니다.
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
    
    @Environment(\.colorScheme) var colorScheme
    @State var capture: NSImage?
    
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .overlay {
                    if ImageRenderer(content: TimelineLayoutView()).nsImage != nil {
                        Image(nsImage: ImageRenderer(content: TimelineLayoutView()).nsImage!)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Thumbnail")
                            .foregroundStyle(Color.subtitle)
                    }
                }
                .foregroundStyle(Color.item)
                .frame(width: 436, height: 330)
            RoundedRectangle(cornerRadius: 8)
                .overlay {
                    VStack(alignment: .leading) {
                        HStack(spacing: 8) {
                            RadioButton(isSelected: periodSelection == .allPeriods)
                                .onTapGesture { periodSelection = .allPeriods }
                                .padding(.leading, 16)
                            Text("기간 모두")
                                .foregroundStyle(Color.title)
                        }
                        HStack {
                            RadioButton(isSelected: periodSelection == .setPeriods)
                                .onTapGesture { periodSelection = .setPeriods }
                                .padding(.leading, 16)
                            Text("기간 설정")
                                .foregroundStyle(Color.title)
                            Spacer()
                                .frame(width: 16)
                            Button(action: {
                                isStartDatePickerPresented = true
                            }) {
                                Text("시작 : \(formattedDate(date: selectedStartDate))")
                                    .foregroundStyle(Color.title)
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
                                    .foregroundStyle(Color.title)
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
                Button(action: {
                    shareImage()
                }) {
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
                Button(action: {
                    dismiss()
                }) {
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
                Button(action: {
                    saveImage()
                }) {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(createHovered ? Color.itemHovered : Color.item)
                        .frame(width: 80, height: 24)
                        .overlay(
                            Text("Save")
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
    @MainActor func shareImage() {
        if let contentView = NSApp.keyWindow?.contentView {
            let image = ImageRenderer(content: TimelineLayoutView().environment(\.colorScheme, colorScheme)).nsImage
            let sharingServicePicker = NSSharingServicePicker(items: [image!])
            
            sharingServicePicker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        return formatter.string(from: date)
    }
    
    @MainActor func saveImage() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save your image"
        savePanel.message = "Choose a folder and a name to store the image."
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                let renderer = ImageRenderer(content: TimelineLayoutView().environment(\.colorScheme, self.colorScheme))
                if let image = renderer.nsImage {
                    self.savePNG(image: image, url: url)
                } else {
                    print("Could not generate image from TimelineLayoutView")
                }
            }
        }
    }
    
    func savePNG(image: NSImage, url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG representation of image")
            return
        }
        do {
            try pngData.write(to: url)
            print("Image successfully saved to \(url.path)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
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
