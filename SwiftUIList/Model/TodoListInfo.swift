//
//  TodoListInfo.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import Foundation

struct TodoListInfo: Codable {
    var todos = [TodoItem]()
    
    struct TodoItem: Codable, Identifiable {
        private(set) var id = UUID().uuidString
        var title = ""
        var description = ""
        var priority = Priorities.mediumPriority
        var dueDate = DueDate(year: 0, month: 0, day: 0, hour: 0, minute: 0, notificationId: "")
        var isCompleted = false
    }
    
    struct DueDate: Codable {
        var year: Int
        var month: Int
        var day: Int
        var hour: Int
        var minute: Int
        var notificationId: String
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(TodoListInfo.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    // To make the SwiftUI preview work we need to use test data
    init(testData: Bool) {
        if !testData {
            loadPersistedJsonData()
        } else {
            loadTestData()
        }
    }
    
    mutating private func loadPersistedJsonData() {
        if let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            if let jsonData = try? Data(contentsOf: url), let savedTodoListInfo = TodoListInfo(json: jsonData) {
                self.todos = savedTodoListInfo.todos
            }
        }
    }
    
    static func persistTodoList(_ todoListInfo: TodoListInfo) {
        if let json = todoListInfo.json, let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("TodoList.json") {
            do {
                try json.write(to: url)
            } catch let error {
                print("Couldn't save: \(error)")
            }
        }
    }
    
    // Test data for SwiftUI preview
    mutating private func loadTestData() {
        self.todos = [
            TodoItem(title: "Medium priority taks",
                     description: "Description for medium priority task",
                     priority: Priorities.mediumPriority,
                     isCompleted: false),
            TodoItem(title: "High priority taks",
                     description: "Description for high priority task",
                     priority: Priorities.highPriority,
                     isCompleted: false),
            TodoItem(title: "Low priority taks",
                     description: "Description for low priority task",
                     priority: Priorities.lowPriority,
                     isCompleted: false),
            TodoItem(title: "High priority completed",
                     description: "Description for a completed high priority task",
                     priority: Priorities.highPriority,
                     isCompleted: true),
            TodoItem(title: "Task with notification",
                     description: "Description for a task with a reminder",
                     priority: Priorities.mediumPriority,
                     dueDate: DueDate(year: 2021, month: 05, day: 25, hour: 14, minute: 15, notificationId: "1"),
                     isCompleted: false),
            TodoItem(title: "Task with a long description",
                     description: "Description for a task with a long description. This descpription will span multiple lines on an iPhone.",
                     priority: Priorities.mediumPriority,
                     isCompleted: true),
            TodoItem(title: "Medium priority completed",
                     description: "Description for a completed medium priority task",
                     priority: Priorities.mediumPriority,
                     isCompleted: true),
            TodoItem(title: "Low priority completed",
                     description: "Description for a completed low priority task",
                     priority: Priorities.lowPriority,
                     isCompleted: true)
        ]
    }
}

extension TodoListInfo.DueDate {
    func formattedDateString() -> String {
        let components = DateComponents(year: self.year,
                                        month: self.month,
                                        day: self.day,
                                        hour: self.hour,
                                        minute: self.minute)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm"
        return formatter.string(from: Calendar(identifier: .gregorian).date(from: components)!)
    }
}
