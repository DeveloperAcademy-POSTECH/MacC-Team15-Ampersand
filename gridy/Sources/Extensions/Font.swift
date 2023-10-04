//
//  Font.swift
//  gridy
//
//  Created by 최민규 on 2023/09/27.
//
// MARK: - Variable fonts used in Gridy.

// TODO: - 코드리뷰없이 일단 머지한 파일입니다 반드시 수정 필요~.~

import SwiftUI

func customFont(font: String, size: Int, weight: Font.Weight) -> Font { return Font.custom(String(font), size: CGFloat(size)).weight(weight)
}

extension String {
    struct Fonts {
        static let lexend = "Lexend"
        static let pretendard = "Pretendard"
    }
}
// TODO: Protocole로 만들기
struct FontSystem: Identifiable {
    var id: UUID = UUID()
    var name: String
    var size: Float
    var weight: Font.Weight
    var kerning: Float
    var color: Color
    
    init(name: String, size: Float, weight: Font.Weight, kerning: Float, color: Color) {
          self.name = name
          self.size = size
          self.weight = weight
          self.kerning = kerning
          self.color = color
      }
}

class GridyFonts: ObservableObject {
    @Published var tabBarTitle: FontSystem = FontSystem(name: .Fonts.lexend, size: 24, weight: .bold, kerning: 1, color: .red)
}

struct FontTestView: View {
//    @State private var font: String = "Pretendard"
    @State private var fontWeight: Float = 0.0
    @State private var fontSize: Float = 20.0
    @State private var selectedFont: Int = 0
    let fontWeights: [Font.Weight] = [.light, .regular, .bold]
    let fonts: [String] = [.Fonts.lexend, .Fonts.pretendard]
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack {
                    Text("\(fonts[selectedFont])")
                    Text("Everyone has the right to freedom of thought, conscience and religion")
                        .lineLimit(2)
                    Text("모든 사람은 의견의 자유와 표현의 자유에 대한 권리를 가진다.")
                        .lineLimit(2)
                    Text("1234567890~!@#$%^&*()-_+=:;,.")
                }
                .font(customFont(font: fonts[selectedFont], size: Int(fontSize), weight: fontWeights[Int(fontWeight)]))
                .padding()
                Spacer()
                Picker("Font", selection: $selectedFont) {
                    ForEach(0..<fonts.count, id: \.self) { index in
                        Text(fonts[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Slider(value: $fontWeight, in: 0...2, step: 1)
                Slider(value: $fontSize, in: 0...50, step: 2)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(fonts, id: \.self) { font in
                    FontLanguageView(fontString: font)
                }
            }
        }
        .onAppear {
            listInstalledFonts()
        }
    }
}

struct FontTestView_Previews: PreviewProvider {
    static var previews: some View {
        FontTestView()
            .previewDevice(PreviewDevice(rawValue: "Mac"))
    }
}

struct FontLanguageView: View {
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    let fontString: String
    var body: some View {
        VStack {
            Group {
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.thin)
                    .padding(scaledPadding)
                
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.regular)
                    .padding(scaledPadding)
                
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.bold)
                    .padding(scaledPadding)
            }
            .environment(\.locale, .init(identifier: "en"))
            
            Group {
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.thin)
                    .padding(scaledPadding)
                
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.regular)
                    .padding(scaledPadding)
                
                Text(LocalizedStringKey(fontString))
                    .font(.custom(fontString, size: 16))
                    .fontWeight(.bold)
                    .padding(scaledPadding)
            }
            .environment(\.locale, .init(identifier: "ko"))
        }
    }
}

func listInstalledFonts() {
    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()
    for family in fontFamilies {
        print(family)
        let familyFonts = NSFontManager.shared.availableMembers(ofFontFamily: family)
        if let fonts = familyFonts {
            for font in fonts {
                print("\t\(font)")
            }
        }
    }
}
