//
//  AddEditTodoView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import SwiftUI

struct AddEditTodoView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var todoItem: TodoListInfo.TodoItem
    @Binding var isAddingNewItem: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $todoItem.title)
            }
            Section(header: Text("Description")) {
                TextEditor(text: $todoItem.description)
            }
            Section(header: Text("Priority")) {
                Picker(selection: $todoItem.priority, label: Text("Priority")) {
                    Text("Low priority").tag(Priorities.lowPriority)
                        .foregroundColor(Priorities.getColor(for: Priorities.lowPriority))
                    Text("Medium priority").tag(Priorities.mediumPriority)
                        .foregroundColor(Priorities.getColor(for: Priorities.mediumPriority))
                    Text("High priority").tag(Priorities.highPriority)
                        .foregroundColor(Priorities.getColor(for: Priorities.highPriority))
                }
                .labelsHidden() // Some iOS bug prevents the label from being hidden, will hopefully be fixed
            }
        }
        .navigationTitle(Text("Edit task"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    viewModel.upsert(item: todoItem)
                    if (isAddingNewItem) {
                        isAddingNewItem = false
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(todoItem.title == "")
            }
        }
    }
}

struct AddEditTodoView_Previews: PreviewProvider {
    @State static var isEditingItem = true
    static var previews: some View {
        NavigationView {
            AddEditTodoView(todoItem: TodoListInfo.TodoItem(title: "Medium priority taks",
                                                            description: "Description for medium priority task",
                                                            priority: Priorities.mediumPriority), isAddingNewItem: $isEditingItem)
        }
    }
}
