//
//  AutoCompleteView.swift
//  gridy
//
//  Created by Jin Sang woo on 10/30/23.
//


import SwiftUI


class AutoCompleteViewModel: ObservableObject {
    @Published var inputText: String = "" {
        didSet { filterSuggestions() }
    }
    @Published var suggestions: [String] = ["Lo-Fi Design", "Hi-Fi Design", "Logo Design", "Lozi", "Lion", "HIHI", "HISO"]
    @Published var filteredSuggestions: [String] = []
    @Published var hoveredSuggestion: String? = nil
    @Published var isSelectionCompleted: Bool = false
    
    
    func filterSuggestions() {
        guard !inputText.isEmpty else {
            filteredSuggestions = suggestions
            resetSelectionCompleted()
            return
        }
        filteredSuggestions = suggestions.filter { $0.contains(inputText) }
    }
    
    func updateSelectedText(with text: String) {
        inputText = text
        isSelectionCompleted = true
    }
    
    func resetSelectionCompleted() {
            isSelectionCompleted = false
        }
    
    func setHoveredSuggestion(_ suggestion: String?) {
        hoveredSuggestion = suggestion
    }
    
}

struct AutoCompleteView: View {
    
    @ObservedObject var viewModel: AutoCompleteViewModel
    let lineAreaGridHeight: CGFloat
    
    
    var body: some View {
        VStack(spacing : 0) {
            ForEach(viewModel.filteredSuggestions, id: \.self) { suggestion in
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 5, height: lineAreaGridHeight)
                        .foregroundColor(Color.orange)
                    
                    Spacer()
                        .frame(width : 10)
                    
                    VStack(alignment: .leading) {
                        Text(suggestion)  // title은 Suggestion 모델에 있어야 합니다.
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.hoveredSuggestion == suggestion ? Color.blue : Color.gray.opacity(0.9))
                            .onTapGesture {
                                viewModel.updateSelectedText(with: suggestion)
                            }
                    }
                    Spacer()
                    
                    Circle()
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "info.circle")
                                .imageScale(.large)
                                .foregroundColor(Color.gray)
                        )
                        .foregroundColor(Color.gray.opacity(0.01))
                }
                .onHover { hovering in
                    viewModel.setHoveredSuggestion(hovering ? suggestion : nil)
                }
                .onTapGesture {
                    viewModel.updateSelectedText(with: suggestion)
                }
                
                .frame(height: lineAreaGridHeight)
                .padding()
                .background(viewModel.hoveredSuggestion == suggestion ? Color.gray.opacity(0.2) : Color.clear)
                
            }
        }
        .background(.thickMaterial)
        .shadow(radius: 10)
        
    }
    
}
