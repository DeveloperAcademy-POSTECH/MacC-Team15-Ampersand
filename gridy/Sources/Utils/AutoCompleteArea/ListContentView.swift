////
////  ListContentView.swift
////  SearchBar
////
////  Created by Jin Sang woo on 11/1/23.
////
//
//import SwiftUI
//
//struct ListContentView: View {
//    
//    @ObservedObject var autoCompleteViewModel: AutoCompleteViewModel
//    let listViewHeight: CGFloat = 70
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            ListItemContainer(autoCompleteViewModel: self.autoCompleteViewModel, listViewHeight: listViewHeight)
//        }
//    }
//    
//    
//    struct ListItemContainer: View {
//        @ObservedObject var autoCompleteViewModel: AutoCompleteViewModel
//        let listViewHeight: CGFloat
//        var body: some View {
//            VStack{
//                    ListView(layerIndex: 0, rowIndex: 0, autoCompleteViewModel: autoCompleteViewModel, lineAreaGridHeight: listViewHeight)
//                        .frame(height: listViewHeight)
//                        .border(.green, width: 9)
//            }
//        }
//    }
//}
