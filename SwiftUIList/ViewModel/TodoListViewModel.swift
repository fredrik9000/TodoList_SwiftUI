//
//  TodoListViewModel.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import Foundation
import UserNotifications

class TodoListViewModel: ObservableObject {
    @Published private var todoListInfo: TodoListInfo {
        didSet {
            TodoListInfo.persistTodoList(todoListInfo)
        }
    }

    init(testData: Bool = false) {
        todoListInfo = TodoListInfo(testData: testData)
    }

    var todoListIsEmpty: Bool {
        todoListInfo.todos.isEmpty
    }

    var todoListHasNoCompletedItems: Bool {
        todoListInfo.todos.filter { $0.isCompleted }.isEmpty
    }

    func filteredListOfTodosByTitle(_ searchText: String) -> [TodoListInfo.TodoItem] {
        todoListInfo.todos.filter { searchText.isEmpty || $0.title.lowercased().contains(searchText.lowercased()) }.sorted { calculateSortedBy($0, $1) }
    }

    func upsert(editedItem: TodoListInfo.TodoItem) {
        if let itemIndex = todoListInfo.index(of: editedItem) {
            // Remove existing notification when updating with a new one or simply removing the existing
            if todoListInfo.todos[itemIndex].hasNotification && (!editedItem.hasNotification || todoListInfo.todos[itemIndex].dueDate != editedItem.dueDate) {
                removeNotificationIfPresent(for: todoListInfo.todos[itemIndex])
            }
            addNotification(for: editedItem)
            todoListInfo.todos[itemIndex] = editedItem
        } else {
            addNotification(for: editedItem)
            todoListInfo.todos.append(editedItem)
        }
    }

    func remove(indexSet: IndexSet) {
        // Make sure the list is sorted, as it is in the UI
        todoListInfo.todos.sort(by: { calculateSortedBy($0, $1) })
        indexSet.forEach {
            removeNotificationIfPresent(for: todoListInfo.todos[$0])
        }
        todoListInfo.todos.remove(atOffsets: indexSet)
    }

    func removeCompleted() {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.isCompleted {
                removeNotificationIfPresent(for: $0)
                return false
            } else {
                return true
            }
        }
    }

    func removeAll() {
        todoListInfo.todos.forEach {
            removeNotificationIfPresent(for: $0)
        }
        todoListInfo.todos = []
    }

    private func removeNotificationIfPresent(for item: TodoListInfo.TodoItem) {
        if item.hasNotification && item.dueDateIsValid {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.notificationId])
            if let itemIndex = todoListInfo.index(of: item) {
                todoListInfo.todos[itemIndex].hasNotification = false
            }
        }
    }

    private func addNotification(for item: TodoListInfo.TodoItem) {
        guard item.hasNotification else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task reminder"
        content.body = item.title
        content.sound = .default

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: item.notificationId,
                                  content: content,
                                  trigger: UNCalendarNotificationTrigger(
                                    dateMatching: DateComponents(year: item.dueDate.year,
                                                                 month: item.dueDate.month,
                                                                 day: item.dueDate.day,
                                                                 hour: item.dueDate.hour,
                                                                 minute: item.dueDate.minute),
                                    repeats: false))
        ) { (error) in
            if error != nil {
                // Some error happened, resetting notification id
                if let itemIndex = self.todoListInfo.index(of: item) {
                    self.todoListInfo.todos[itemIndex].hasNotification = false
                }
            }
        }
    }

    func setCompletedState(for item: TodoListInfo.TodoItem, isCompleted: Bool) {
        if let itemIndex = todoListInfo.index(of: item) {
            todoListInfo.todos[itemIndex].isCompleted = isCompleted
            if isCompleted {
                removeNotificationIfPresent(for: item)
            }
        }
    }

    private func calculateSortedBy(_ todoItemLeft: TodoListInfo.TodoItem, _ todoItemRight: TodoListInfo.TodoItem) -> Bool {
        if todoItemLeft.isCompleted != todoItemRight.isCompleted {
            return !todoItemLeft.isCompleted
        } else if todoItemLeft.priority != todoItemRight.priority {
            return todoItemLeft.priority > todoItemRight.priority
        } else if todoItemLeft.title != todoItemRight.title {
            return todoItemLeft.title < todoItemRight.title
        } else {
            return true
        }
    }
}
