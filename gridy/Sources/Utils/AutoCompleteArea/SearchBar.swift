//
//  SearchBarApp.swift
//  SearchBar
//
//  Created by Jin Sang woo on 10/19/23.
//

import SwiftUI

@main
struct SearchBar: App {
    var body: some Scene {
        WindowGroup{
                let viewModel = AutoCompleteViewModel()
                ListContentView(autoCompleteViewModel: viewModel)
                
        }
    }
}
