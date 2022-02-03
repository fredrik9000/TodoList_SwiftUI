//
//  ListItemView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/18/21.
//

import SwiftUI

struct ListItemView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @State var todoItem: TodoListInfo.TodoItem

    var body: some View {
        HStack {
            Toggle("Toggle completed", isOn: $todoItem.isCompleted)
                .labelsHidden()
                .onChange(of: todoItem.isCompleted) { _ in
                    withAnimation {
                        viewModel.setCompletedState(for: todoItem)
                    }
                }
                .toggleStyle(CheckBoxToggleStyle(priority: $todoItem.priority))
                .buttonStyle(PlainButtonStyle()) // In order to avoid triggering navigation when toggling

            NavigationLink(destination: AddEditTodoView(todoItem: todoItem)) {
                VStack(alignment: .leading, spacing: Constants.listItemTextVerticalSpacing) {
                    Text(todoItem.title)

                    if todoItem.hasNotification && todoItem.dueDateIsValid {
                        Text(todoItem.dueDate.formattedDateString()).font(.caption)
                    }
                }
            }
            .disabled(todoItem.isCompleted)
        }
        .padding(Constants.listItemViewPadding)
    }

    private struct Constants {
        static let listItemTextVerticalSpacing: CGFloat = 8
        static let listItemViewPadding: CGFloat = 8
    }
}

private struct CheckBoxToggleStyle: ToggleStyle {
    @Binding var priority: Int
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
        }
        .padding(Constants.completedCheckBoxPadding)
        .font(.title)
        .foregroundColor(Priorities.getColor(for: priority))
    }

    private struct Constants {
        static let completedCheckBoxPadding: CGFloat = 4
    }
}

struct ListItemView_Previews: PreviewProvider {
    @State static var isAddingNewItem = false
    static var previews: some View {
        ListItemView(todoItem: TodoListInfo.TodoItem(
                        title: "Medium priority task",
                        description: "Description for medium priority task",
                        priority: Priorities.mediumPriority))

        ListItemView(todoItem: TodoListInfo.TodoItem(
                        title: "Completed task",
                        description: "Description for completed priority task",
                        priority: Priorities.mediumPriority,
                        isCompleted: true))
    }
}
