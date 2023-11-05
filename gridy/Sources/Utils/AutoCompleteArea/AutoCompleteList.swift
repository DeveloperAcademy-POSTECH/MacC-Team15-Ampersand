//
//  AutoCompleteList.swift
//  gridy
//
//  Created by Jin Sang woo on 11/5/23.
//

import SwiftUI

class AutoCompleteViewModel: ObservableObject {
    
    @Published var suggestions: [String] = ["Lo-Fi Design", "Hi-Fi Design", "Logo Design", "Lozi", "Lion", "HIHI", "HISO"]
    @Published var filteredSuggestions: [String] = []
    @Published var hoveredSuggestion: String? = nil
    @Published var isSelectionCompleted: Bool = false
    @Published var inputText: String = "" {
        didSet { filterSuggestions() }
    }
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

struct SuggestionRow: View {
    var suggestion: String
    @ObservedObject var viewModel: AutoCompleteViewModel
    var lineAreaGridHeight: CGFloat

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 5, height: lineAreaGridHeight)
                .foregroundColor(Color.orange)
            
            Spacer()
                .frame(width : 10)
            
            VStack(alignment: .leading) {
                Text(suggestion)
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.hoveredSuggestion == suggestion ? Color.blue : Color.gray.opacity(0.85))
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
    }
}

struct AutoCompleteView: View {
    @ObservedObject var viewModel: AutoCompleteViewModel
    let lineAreaGridHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredSuggestions, id: \.self) { suggestion in
                SuggestionRow(suggestion: suggestion, viewModel: viewModel, lineAreaGridHeight: lineAreaGridHeight)
                    .frame(height: lineAreaGridHeight)
                    .padding()
                    .background(viewModel.hoveredSuggestion == suggestion ? Color.gray.opacity(0.2) : Color.clear)
            }
        }
    }
}

struct ListContentView: View {
    @ObservedObject var autoCompleteViewModel: AutoCompleteViewModel
    let listViewHeight: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 10) {
            ListView(layerIndex: 0, rowIndex: 0, autoCompleteViewModel: autoCompleteViewModel, lineAreaGridHeight: listViewHeight)
                .frame(height: listViewHeight)
                .border(.green, width: 9)
        }
    }
}

struct ListView: View {
    
    let fontSize: CGFloat = 14
    
    /// 호버, 클릭, 더블 클릭을 트래킹하는 변수들.
    @FocusState var isTextFieldFocused: Bool
    @State var isHovering = false
    @State var isSelected = false
    @State var isEditing = false
    @State var editingText =  ""
    @State var prevText = ""
    
    var layerIndex: Int
    var rowIndex: Int
    
    /// AutoComplete Model
    @State private var textFieldRect: CGRect = .zero
    @State private var textFieldHeight: CGFloat = 0
    
    @ObservedObject var autoCompleteViewModel: AutoCompleteViewModel
    let lineAreaGridHeight: CGFloat
    
    var body: some View {
        ZStack(){
            GeometryReader { geometry in
                ZStack {
                    // MARK: - 초기 상태.
                    /// 빈 Text를 보여준다.  클릭, 더블클릭이 가능하고 호버링이 되면 배경이 회색으로 변경된다.
                    if !isSelected && !isEditing {
                        Rectangle()
                            .foregroundStyle(isHovering ? Color.gray.opacity(0.2) : Color.clear)
                            .overlay(
                                Text(editingText)
                            )
                            .onHover { phase in
                                if !isSelected && !isEditing {
                                    isHovering = phase
                                }
                            }
                            .onTapGesture {
                                isHovering = false
                                isSelected = true
                            }
                            .highPriorityGesture(TapGesture(count: 2).onEnded({
                                isHovering = false
                                isSelected = false
                                isEditing = true
                                isTextFieldFocused = true
                                prevText = editingText
                            }))
                    }
                    
                    // MARK: - 한 번 클릭 된 상태.
                    /// 호버링 상태를 추적하지 않는다. 흰 배경에 보더만 파란 상태. 더블 클릭이 가능하다.
                    if isSelected {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.white)
                            Rectangle()
                                .strokeBorder(Color.blue)
                                .overlay(
                                    Text(editingText)
                                        .lineLimit(2)
                                        .font(.custom("Pretendard-Regular", size: fontSize))
                                        .padding(.horizontal, 8)
                                )
                        }
                        .onTapGesture(count: 2) {
                            isSelected = false
                            isEditing = true
                            isTextFieldFocused = true
                            prevText = editingText
                        }
                        .contextMenu {
                            Button {
                                // TODO: - createPlan, 인자 true
                            } label: {
                                Text("Add a lane above")
                            }
                            
                            Button {
                                // TODO: - createPlan, 인자 false
                            } label: {
                                Text("Add a lane below")
                            }
                        }
                    }
                    
                    // MARK: - 더블 클릭 된 상태.
                    /// 호버링 상태를 추적하지 않는다. 텍스트 필드가 활성화 된다. 엔터를 누르면 텍스트가 변경되고, esc를 누르면 이전 text를 보여주는 초기 상태로 돌아간다.
                    if isEditing{
                        ZStack(alignment: .top){
                            Rectangle()
                                .strokeBorder(Color.clear)
                                .overlay {
                                    TextField("Editing", text: $autoCompleteViewModel.inputText, onCommit: {
                                        isEditing = false
                                    })
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    .onSubmit {
                                        isEditing = false
                                        isTextFieldFocused = false
                                        // TODO: - PlanType Title Change
                                    }
                                    .overlay(
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    self.textFieldHeight = geometry.size.height
                                                }
                                        }
                                    )
                                    .multilineTextAlignment(.center)
                                    .font(.custom("Pretendard-Medium", size: fontSize))
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 1)
                                    .padding(.vertical, 2)
                                    // TODO: - 로이스 focus 적용
                                    .focused($isTextFieldFocused)
                                    .onExitCommand {
                                        editingText = prevText
                                        isEditing = false
                                        isTextFieldFocused = false
                                    }
                                }
                            
                            if !autoCompleteViewModel.filteredSuggestions.isEmpty && !autoCompleteViewModel.isSelectionCompleted   {
                                AutoCompleteView(viewModel: autoCompleteViewModel, lineAreaGridHeight: geometry.size.height)
                                    .offset(y: geometry.size.height)
                            }
                        }
                    }
                }
            }
        }
    }
}
