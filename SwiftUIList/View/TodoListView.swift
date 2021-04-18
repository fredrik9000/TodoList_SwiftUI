//
//  TodoListView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var isAddingNewItem = false
    
    var body: some View {
        NavigationView {
            // Due to a SwiftUI bug causing AddEditTodoView to be pushed again after pressing done,
            // isActive based navigation is used.
            VStack(spacing: 0) {
                NavigationLink(
                    destination: AddEditTodoView(todoItem: TodoListInfo.TodoItem(), isAddingNewItem: $isAddingNewItem),
                    isActive: $isAddingNewItem) {
                    EmptyView()
                }.hidden()
                
                if viewModel.listOfTodos.count == 0 {
                    Text("Add tasks by tapping the plus button")
                        .font(.largeTitle)
                        .offset(y: -50)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.listOfTodos) { todoItem in
                            NavigationLink(destination: AddEditTodoView(todoItem: todoItem, isAddingNewItem: $isAddingNewItem)) {
                                ListItemView(todoItem: todoItem)
                            }
                            .animation(nil) // Prevent animating row internals
                        }
                        .onDelete {
                            viewModel.remove(indexSet: $0)
                        }
                    }
                    .animation(.easeInOut) // Adds animation to completed toggling and deletion
                }
            }
            .navigationTitle("Things to do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Remove completed items") {
                            viewModel.removeCompleted()
                        }
                        Button("Remove all items") {
                            viewModel.removeAll()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddingNewItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            isAddingNewItem = false
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoListViewModel(testData: true))
    }
}
