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
    @State private var searchText = ""

    /*
     // Adding animation to the binding causes a race condition for what's shown when typing quickly
     private var searchBinding: Binding<String> {
        Binding<String>(
            get: { return self.searchText },
            set: { newSearchText in
                withAnimation {
                    self.searchText = newSearchText
                }
            }
        )
    }*/

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Due to a SwiftUI bug causing AddEditTodoView to be pushed again after pressing done,
                // isActive based navigation is used.
                NavigationLink(
                    destination: AddEditTodoView(todoItem: TodoListInfo.TodoItem(), isAddingNewItem: $isAddingNewItem),
                    isActive: $isAddingNewItem) {
                    EmptyView()
                }
                .hidden()

                SearchBar(text: $searchText)

                if viewModel.todoListIsEmpty {
                    Text("Add tasks by tapping the plus button")
                        .font(.largeTitle)
                        .offset(y: Constants.onboardingHeaderYOffset)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredListOfTodosByTitle(searchText)) { todoItem in
                            ListItemView(todoItem: todoItem, isAddingNewItem: $isAddingNewItem)
                        }
                        .onDelete {
                            viewModel.remove(indexSet: $0)
                        }
                    }
                }
            }
            .navigationTitle("Things to do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addTodoButton
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            isAddingNewItem = false
        }
    }

    private var deleteMenu: some View {
        return Menu {
            Button("Remove completed items") {
                withAnimation {
                    viewModel.removeCompleted()
                }
            }
            Button("Remove all items") {
                withAnimation {
                    viewModel.removeAll()
                }
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private var addTodoButton: some View {
        Button {
            withAnimation {
                isAddingNewItem = true
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    private struct Constants {
        static let onboardingHeaderYOffset: CGFloat = -50
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoListViewModel(testData: true))
    }
}
