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
                .onChange(of: todoItem) { value in
                    viewModel.toggleCompleted(for: value)
                }
                .toggleStyle(CheckBoxToggleStyle(priority: $todoItem.priority))
                .buttonStyle(PlainButtonStyle()) // In order to avoid triggering navigation when toggling
            
            VStack(alignment: .leading, spacing: 8) {
                Text(todoItem.title)
                
                if todoItem.hasNotification() {
                    Text(todoItem.dueDate.formattedDateString())
                        .font(.caption)
                }
            }
        }
        .padding(8)
    }
}

private struct CheckBoxToggleStyle: ToggleStyle {
    @Binding var priority: Int
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
            .padding(4)
            .font(.title)
            .foregroundColor(Priorities.getColor(for: priority))
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(todoItem: TodoListInfo.TodoItem(
                        title: "Medium priority taks",
                        description: "Description for medium priority task",
                        priority: Priorities.mediumPriority))
    }
}
