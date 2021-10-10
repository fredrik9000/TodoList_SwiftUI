//
//  TodoListInfo.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import Foundation

struct TodoListInfo: Codable {
    var todos = [TodoItem]()

    struct TodoItem: Codable, Identifiable, Equatable {
        private(set) var id = UUID().uuidString
        var title = ""
        var description = ""
        var priority = Priorities.mediumPriority
        var isCompleted = false
        var dueDate = DueDate(year: 0, month: 0, day: 0, hour: 0, minute: 0)
        private(set) var notificationId = UUID().uuidString
        var hasNotification = false

        var dueDateIsValid: Bool {
            dueDate.toSwiftDate().timeIntervalSinceNow.sign != .minus
        }

        mutating func generateNewId() {
            id = UUID().uuidString
        }

        struct DueDate: Codable, Equatable {
            var year: Int
            var month: Int
            var day: Int
            var hour: Int
            var minute: Int

            func toSwiftDate() -> Date {
                Calendar.current.date(from: DateComponents(year: year,
                                                                  month: month,
                                                                  day: day,
                                                                  hour: hour,
                                                                  minute: minute))!
            }

            func fromSwiftDate(_ date: Date) -> TodoListInfo.TodoItem.DueDate {
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                return TodoListInfo.TodoItem.DueDate(
                    year: dateComponents.year!,
                    month: dateComponents.month!,
                    day: dateComponents.day!,
                    hour: dateComponents.hour!,
                    minute: dateComponents.minute!
                )
            }

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
    }

    func index(of item: TodoItem) -> Int? {
        todos.firstIndex(where: { $0.id == item.id })
    }

    var json: Data? {
        try? JSONEncoder().encode(self)
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
                print("Couldn't save, error: \(error)")
            }
        }
    }

    // Test data for SwiftUI preview
    mutating private func loadTestData() {
        self.todos = [
            TodoItem(title: "Medium priority task",
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
                     isCompleted: false,
                     dueDate: TodoItem.DueDate(year: 2021, month: 05, day: 25, hour: 14, minute: 15)),
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
