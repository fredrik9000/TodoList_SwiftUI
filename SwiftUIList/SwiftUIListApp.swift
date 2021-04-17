//
//  SwiftUIListApp.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import SwiftUI

@main
struct SwiftUIListApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView().environmentObject(TodoListViewModel())
        }
    }
}
