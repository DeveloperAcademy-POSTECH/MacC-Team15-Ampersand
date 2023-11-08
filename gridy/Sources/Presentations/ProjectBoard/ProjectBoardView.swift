//
//  ProjectBoardView.swift
//  gridy
//
//  Created by 제나 on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct ProjectBoardView: View {
    @State var bellButtonClicked = false
    @State var userSettingClicked = false
    @State var themeClicked = false
    @State var planBoardButtonClicked = false
    
    @State var automaticClicked = false
    @State var lightClicked = false
    @State var darkClicked = false
    
    @State private var isExpanded = false
    @State private var searchPlanBoardText = ""
    
    @State private var currentDate: Date = Date()
    @State private var currentMonth: Int = 0
    @State private var isDayClicked: Bool = false
    @State private var selectedDate: DateValue = DateValue(day: 0, date: Date())
    let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    let store: StoreOf<ProjectBoard>
    let planBoardStore = Store(
        initialState: PlanBoard.State(
            rootProject: Project(
                id: "id",
                title: "title",
                ownerUid: "uid",
                createdDate: Date(),
                lastModifiedDate: Date(),
                map: ["": [""]]
            ), map: ["": [""]]
        )
    ) {
        PlanBoard()
            ._printChanges()
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isUserSettingPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isUserSettingPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .userSettingButton,
                            bool: newValue
                        ))
                    }
                )
            }
            VStack(alignment: .leading, spacing: 0) {
                TabBarView(bellButtonClicked: $bellButtonClicked, store: store)
                    .frame(height: 36)
                    .zIndex(2)
                if viewStore.tabBarFocusGroupClickedItem == .homeButton {
                    systemBorder(.horizontal)
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            userSettingArea
                                .popover(isPresented: isUserSettingPresented, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                                    UserSettingView(themeClicked: $themeClicked)
                                        .popover(isPresented: $themeClicked, arrowEdge: .trailing) {
                                            themeSelect
                                        }
                                }
                            systemBorder(.horizontal)
                            calendarArea
                                .frame(height: 280)
                                .padding(.horizontal, 16)
                            systemBorder(.horizontal)
                            boardSearchArea
                            projectListArea
                            Spacer()
                        }
                        .background(Color.sideBar.shadow(
                            color: .black.opacity(0.2),
                            radius: 16,
                            x: 8
                        ))
                        .frame(width: 280)
                        .zIndex(1)
                        systemBorder(.vertical)
                        listArea
                    }
                } else {
                    PlanBoardView(
                        store: planBoardStore,
                        tabID: viewStore.tabBarFocusGroupClickedItem
                    )
                }
            }
        }
        .sheet(isPresented: $planBoardButtonClicked) {
            CreatePlanBoardView()
        }
    }
}

extension ProjectBoardView {
    var userSettingArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .foregroundStyle(Color.blackWhite)
                    .frame(width: 24, height: 24)
                Text("HongGilDong")
                    .foregroundStyle(Color.title)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .foregroundStyle(Color.subtitle)
            }
            .padding(8)
            .background {
                if viewStore.isUserSettingPresented ||
                    viewStore.hoveredItem == .userSettingButton {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.itemHovered)
                }
            }
            .padding(8)
            .frame(height: 48)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? .userSettingButton : "")
                )
            }
            .onTapGesture {
                viewStore.send(.popoverPresent(
                    button: .userSettingButton,
                    bool: !viewStore.isUserSettingPresented
                ))
            }
        }
    }
}

extension ProjectBoardView {
    var calendarArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(viewStore.hoveredItem == "calendarArea" ? Color.itemHovered : Color.item)
                .frame(width: 248, height: 248)
                .overlay {
                    GeometryReader { _ in
                        VStack(alignment: .center, spacing: 4) {
                            HStack(alignment: .center, spacing: 16) {
                                Text(extraDate()[1])
                                    .foregroundStyle(Color.black)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.body)
                                    .foregroundColor(Color.gray)
                                    .onTapGesture { currentMonth -= 1 }
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .foregroundColor(Color.gray)
                                    .onTapGesture { currentMonth += 1 }
                            }
                            .padding(.horizontal, 24)
                            HStack(alignment: .top, spacing: 5) {
                                ForEach(days, id: \.self) { day in
                                    Text(day)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(day == "일" ? Color.gray : Color.black)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            let columns = Array(repeating: GridItem(.fixed(25), spacing: 5), count: 7)
                            LazyVGrid(columns: columns, spacing: extractDate().count > 35 ? 0 : 6) {
                                ForEach(extractDate()) { value in
                                    cardView(value: value)
                                }
                            }
                            .onChange(of: currentMonth) { _ in
                                currentDate = getCurrentMonth()
                            }
                            Spacer()
                        }
                    }
                    .offset(y: 24)
                }
                .scaleEffect(viewStore.hoveredItem == "calendarArea" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "calendarArea" : ""))
                }
        }
    }
    
    struct DateValue: Identifiable {
        var id = UUID().uuidString
        var day: Int
        var date: Date
    }
    
    @ViewBuilder
    func cardView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isToday = Calendar.current.isDateInToday(value.date)
                let comparisonResult = Calendar.current.compare(value.date, to: Date(), toGranularity: .day)
                let isSunday = value.date.dayOfSunday() == 1
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(isToday ? Color.black : .clear)
                Text("\(value.day)")
                    .font(.title3)
                    .bold(isToday ? true : false)
                    .foregroundColor(isSunday ? Color.gray : isToday ? Color.white : Color.black)
            }
        }
    }
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        /// 현재 달의 요일을 받아옴
        guard let currentMonth = calendar.date(byAdding: .month, value : self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

extension ProjectBoardView {
    var boardSearchArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(viewStore.hoveredItem == "searchTextFieldHover" ? Color.itemHovered : .item)
                    .frame(height: 32)
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20, height: 20)
                    TextField("Search", text: $searchPlanBoardText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            .padding(8)
            .onHover { isHovered in
                viewStore.send(.hoveredItem(name: isHovered ? "searchTextFieldHover" : ""))
            }
        }
    }
}

extension ProjectBoardView {
    var projectListArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section(header: Text("Projects")
                .fontWeight(.medium)
                .padding(.leading, 16)
                .padding(.bottom, 8)
            ) {
                ScrollView(showsIndicators: false) {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        ForEach(0..<4, id: \.self) { index in
                            Folder(store: store, id: index)
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.subtitle)
                                )
                            Label("Personal Project", systemImage: "person.crop.square.fill")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.title)
                                .frame(height: 40)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .onHover { isHovered in
                            viewStore.send(.hoveredItem(name: isHovered ? "personalProject" : ""))
                        }
                        .background(
                            //                            viewStore.projectListFocusGroupClickedItem == "personalProject"
                            isExpanded ||
                            viewStore.hoveredItem == "personalProject" ?
                            Color.itemHovered : .clear
                        )
                        .onTapGesture {
                            isExpanded.toggle()
                            viewStore.send(.clickedItem(
                                focusGroup: .projectListFocusGroup,
                                name: "personalProject")
                            )
                        }
                    }
                }
                .disclosureGroupStyle(MyDisclosureStyle())
            }
        }
    }
    
    private struct Folder: View {
        let store: StoreOf<ProjectBoard>
        var id: Int
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                HStack(alignment: .center, spacing: 0) {
                    Text("Folder")
                        .foregroundStyle(Color.title)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.leading, 64)
                .frame(height: 40)
                .background(viewStore.hoveredItem == "folderId_\(id)" ||
                            viewStore.folderListFocusGroupClickedItem == "folderId_\(id)" ?
                            Color.itemHovered.opacity(0.5) : .clear)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(
                        name: isHovered ?
                        "folderId_\(id)" : "")
                    )
                }
                .onTapGesture {
                    viewStore.send(.clickedItem(
                        focusGroup: .folderListFocusGroup,
                        name: "folderId_\(id)")
                    )
                }
            }
        }
    }
    
    private struct MyDisclosureStyle: DisclosureGroupStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                if configuration.isExpanded {
                    configuration.content
                }
            }
        }
    }
}

extension ProjectBoardView {
    var listArea: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            var isCreatePlanBoardPresented: Binding<Bool> {
                Binding(
                    get: { viewStore.isCreatePlanBoardPresented },
                    set: { newValue in
                        viewStore.send(.popoverPresent(
                            button: .createPlanBoardButton,
                            bool: newValue
                        ))
                    }
                )
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(viewStore.hoveredItem == .galleryBackButton ? Color.title : .subtitle)
                        .fontWeight(viewStore.hoveredItem == .galleryBackButton ? .bold : .medium)
                        .padding(8)
                        .frame(width: 32, height: 32)
                        .scaleEffect(viewStore.hoveredItem == .galleryBackButton ? 1.02 : 1)
                        .onTapGesture {
                            // TODO: - Back Button Clicked
                        }
                        .onHover { isHovered in
                            viewStore.send(.hoveredItem(name: isHovered ? .galleryBackButton : ""))
                        }
                    Text("Folder")
                        .font(.title)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        viewStore.send(.popoverPresent(
                            button: .createPlanBoardButton,
                            bool: true
                        ))
                    } label: {
                        RoundedRectangle(cornerRadius: 22)
                            .foregroundStyle(viewStore.hoveredItem == .createPlanBoardButton ?
                                             Color.boardSelectedBorder : Color.button)
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 4,
                                y: 4
                            )
                            .frame(width: 125, height: 44)
                            .overlay(
                                Text("+ Plan Board")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.buttonText)
                            )
                    }
                    .buttonStyle(.link)
                    .scaleEffect(viewStore.hoveredItem == .createPlanBoardButton ? 1.01 : 1)
                    .onHover { isHovered in
                        viewStore.send(.hoveredItem(name: isHovered ? .createPlanBoardButton : ""))
                    }
                }
                .padding(16)
                .padding(.trailing, 16)
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(0..<20, id: \.self) { index in
                                PlanBoardItem(store: store, id: index)
                            }
                        }
                        .padding(32)
                    }
                    .background(Color.folder)
                    LinearGradient(colors: [.clear, .folder], startPoint: .top, endPoint: .bottom)
                        .frame(height: 48)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.leading, 32)
                .padding([.trailing, .bottom], 16)
            }
            .background(Color.project)
            .sheet(isPresented: isCreatePlanBoardPresented) {
                CreatePlanBoardView()
            }
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 240, maximum: 360), spacing: 32)]
    }
    
    private struct PlanBoardItem: View {
        let store: StoreOf<ProjectBoard>
        var id: Int
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(Color.board)
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(viewStore.hoveredItem == .planBoardItemButton + "\(id)" ? Color.boardHoveredBorder : .clear)
                            .shadow(
                                color: viewStore.hoveredItem == .planBoardItemButton + "\(id)" ? .black.opacity(0.25) : .clear,
                                radius: 8
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
                    .aspectRatio(3/2, contentMode: .fit)
                    .shadow(
                        color: viewStore.hoveredItem == .planBoardItemButton + "\(id)" ? .black.opacity(0.25) : .clear,
                        radius: 4,
                        y: 4
                    )
                    Spacer().frame(height: 8)
                    Text("Board Name")
                        .fontWeight(.medium)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.title)
                    Text("2023.10.01 ~ 2023.11.14")
                        .font(.caption)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.subtitle)
                    Text("Last updated on 2023.10.17")
                        .font(.caption)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.textInactive)
                }
                .scaleEffect(viewStore.hoveredItem == .planBoardItemButton + "\(id)" ? 1.02 : 1)
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? .planBoardItemButton + "\(id)" : ""))
                }
            }
        }
    }
}

extension ProjectBoardView {
    var themeSelect: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Automatic")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(automaticClicked ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(automaticClicked ? Color.blackWhite : viewStore.hoveredItem == "automatic" ? Color.blackWhite : .clear)
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "automatic" : ""))
                }
                .onTapGesture {
                    automaticClicked = true
                    lightClicked = false
                    darkClicked = false
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text("Light")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(lightClicked ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(lightClicked ? Color.blackWhite : viewStore.hoveredItem == "light" ? Color.blackWhite : .clear)
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "light" : ""))
                }
                .onTapGesture {
                    automaticClicked = false
                    lightClicked = true
                    darkClicked = false
                }
                
                HStack(alignment: .center, spacing: 0) {
                    Text("Dark")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.title)
                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(darkClicked ? Color.title : .clear)
                }
                .frame(height: 40)
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(darkClicked ? Color.blackWhite : viewStore.hoveredItem == "dark" ? Color.blackWhite : .clear)
                )
                .onHover { isHovered in
                    viewStore.send(.hoveredItem(name: isHovered ? "dark" : ""))
                }
                .onTapGesture {
                    automaticClicked = false
                    lightClicked = false
                    darkClicked = true
                }
            }
            .padding(16)
            .frame(width: 170, height: 168)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.blackWhite.opacity(0.3))
            )
        }
    }
}
