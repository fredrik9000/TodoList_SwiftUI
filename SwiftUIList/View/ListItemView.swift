//
//  ListItemView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/18/21.
//

import SwiftUI

struct ListItemView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    let todoItem: TodoListInfo.TodoItem

    private var isCompletedBinding: Binding<Bool> {
        Binding<Bool>(
            get: { todoItem.isCompleted },
            set: { isCompleted in
                withAnimation {
                    viewModel.setCompletedState(for: todoItem, isCompleted: isCompleted)
                }
            }
        )
    }

    var body: some View {
        HStack {
            Toggle("Toggle completed", isOn: isCompletedBinding)
                .labelsHidden()
                .toggleStyle(CheckBoxToggleStyle(priority: todoItem.priority))
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
    var priority: Int
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
        }
        .padding(Constants.completedCheckBoxPadding)
        .font(.title)
        .foregroundColor(Priority(rawValue: priority)!.color)
    }

    private struct Constants {
        static let completedCheckBoxPadding: CGFloat = 4
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(
            todoItem: TodoListInfo.TodoItem(
                title: "Medium priority task",
                description: "Description for medium priority task",
                priority: Priority.medium.rawValue
            )
        )

        ListItemView(
            todoItem: TodoListInfo.TodoItem(
                title: "Completed task",
                description: "Description for completed priority task",
                priority: Priority.medium.rawValue,
                isCompleted: true
            )
        )
    }
}
