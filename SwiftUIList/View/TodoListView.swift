//
//  TodoListView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var searchText = ""

    private var searchBinding: Binding<String> {
        Binding<String>(
            get: { return self.searchText },
            set: { newSearchText in
                withAnimation {
                    self.searchText = newSearchText
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.todoListIsEmpty {
                    Text("Add tasks by tapping the plus button")
                        .font(.largeTitle)
                        .offset(y: Constants.onboardingHeaderYOffset)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredListOfTodosByTitle(searchText)) { todoItem in
                            ListItemView(todoItem: todoItem)
                        }
                        .onDelete {
                            viewModel.remove(indexSet: $0)
                        }
                    }
                    .searchable(text: searchBinding)
                }
            }
            .navigationTitle("Things to do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditTodoView(todoItem: TodoListInfo.TodoItem())) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
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

    private struct Constants {
        static let onboardingHeaderYOffset: CGFloat = -50
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoListViewModel(testData: true))
    }
}
