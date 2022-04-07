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
    @State private var isShowingDeleteItemsConfirmationDialog = false

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
                    Button(role: .destructive) {
                        isShowingDeleteItemsConfirmationDialog = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(viewModel.todoListIsEmpty)
                    .confirmationDialog(
                        "Are you sure you want to delete items?",
                        isPresented: $isShowingDeleteItemsConfirmationDialog,
                        titleVisibility: .visible
                    ) {
                        Button("Remove completed items", role: .destructive) {
                            withAnimation {
                                viewModel.removeCompleted()
                            }
                        }
                        .disabled(viewModel.todoListHasNoCompletedItems)

                        Button("Remove all items", role: .destructive) {
                            withAnimation {
                                viewModel.removeAll()
                            }
                        }
                    }
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

    private struct Constants {
        static let onboardingHeaderYOffset: CGFloat = -50
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoListViewModel(testData: true))
    }
}
