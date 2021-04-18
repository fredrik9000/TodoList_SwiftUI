//
//  TodoListViewModel.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import Foundation
import Combine
import UserNotifications

class TodoListViewModel: ObservableObject {
    @Published private var todoListInfo: TodoListInfo
    private var autoSaveCancellable: AnyCancellable?
    
    init(testData: Bool = false) {
        todoListInfo = TodoListInfo(testData: testData)
        autoSaveCancellable = $todoListInfo.sink {
            TodoListInfo.persistTodoList($0)
        }
    }
    
    var listOfTodos: [TodoListInfo.TodoItem] {
        todoListInfo.todos.sorted(by: { calculateSortedBy($0, $1) })
    }
    
    func upsert(item: TodoListInfo.TodoItem) {
        if let itemIndex = todoListInfo.todos.firstIndex(where: { $0.id == item.id }) {
            if todoListInfo.todos[itemIndex].hasNotification() &&
                    todoListInfo.todos[itemIndex].dueDate.notificationId != item.dueDate.notificationId {
                removeNotificationIfPresent(for: todoListInfo.todos[itemIndex])
                addNotificationIfSet(for: item)
            }
            todoListInfo.todos[itemIndex] = item
        } else {
            addNotificationIfSet(for: item)
            todoListInfo.todos.append(item)
            todoListInfo.todos.sort(by: { calculateSortedBy($0, $1) })
        }
    }
    
    func remove(indexSet: IndexSet) {
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
        if item.hasNotification() {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.dueDate.notificationId])
            if let itemIndex = todoListInfo.todos.firstIndex(where: { $0.id == item.id }) {
                todoListInfo.todos[itemIndex].dueDate.notificationId = ""
            }
        }
    }

    private func addNotificationIfSet(for item: TodoListInfo.TodoItem) {
        guard item.hasNotification() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task reminder"
        content.body = item.title
        content.sound = .default

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: item.dueDate.notificationId,
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
                if let itemIndex = self.todoListInfo.todos.firstIndex(where: { $0.id == item.id }) {
                    self.todoListInfo.todos[itemIndex].dueDate.notificationId = ""
                }
            }
        }
    }

    func toggleCompleted(for item: TodoListInfo.TodoItem) {
        if let itemIndex = todoListInfo.todos.firstIndex(where: { $0.id == item.id }) {
            todoListInfo.todos[itemIndex].isCompleted = !todoListInfo.todos[itemIndex].isCompleted
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
