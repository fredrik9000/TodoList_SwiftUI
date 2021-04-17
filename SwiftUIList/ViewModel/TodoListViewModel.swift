//
//  TodoListViewModel.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import Foundation
import Combine

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
            todoListInfo.todos[itemIndex] = item
        } else {
            todoListInfo.todos.append(item)
            todoListInfo.todos.sort(by: { calculateSortedBy($0, $1) })
        }
    }
    
    func remove(indexSet: IndexSet) {
        todoListInfo.todos.remove(atOffsets: indexSet)
    }
    
    func removeCompleted() {
        todoListInfo.todos = todoListInfo.todos.filter {
            if $0.isCompleted {
                return false
            } else {
                return true
            }
        }
    }
    
    func removeAll() {
        todoListInfo.todos = []
    }
    
    private func calculateSortedBy(_ todoItemLeft: TodoListInfo.TodoItem, _ todoItemRight: TodoListInfo.TodoItem) -> Bool {
        return todoItemLeft.priority > todoItemRight.priority || todoItemLeft.title <= todoItemRight.title
    }
}
