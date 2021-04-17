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
                List {
                    ForEach(viewModel.listOfTodos) { todoItem in
                        ItemCellView(todoItem: todoItem, isAddingNewItem: $isAddingNewItem)
                    }
                    .onDelete {
                        viewModel.remove(indexSet: $0)
                    }
                }
            }
            .navigationTitle("Things to do")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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

private struct ItemCellView: View {
    var todoItem: TodoListInfo.TodoItem
    @Binding var isAddingNewItem: Bool
    
    var body: some View {
        HStack {
            NavigationLink(destination: AddEditTodoView(todoItem: todoItem, isAddingNewItem: $isAddingNewItem)) {
                Text(todoItem.title)
            }
        }
        .padding()
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoListViewModel(testData: true))
    }
}
