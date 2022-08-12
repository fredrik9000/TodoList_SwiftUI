//
//  AddEditTodoView.swift
//  SwiftUIList
//
//  Created by Fredrik Eilertsen on 4/10/21.
//

import SwiftUI
import UserNotifications

struct AddEditTodoView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var todoItem: TodoListInfo.TodoItem
    @State private var showNotificationExpiredDialog = false
    @State private var notificationIsNotAuthorized = false
    @State private var insertOrUpdateNotification = false

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $todoItem.title)
            }
            Section(header: Text("Description")) {
                TextEditor(text: $todoItem.description)
            }
            Section(header: Text("Priority")) {
                PrioritySectionView(priority: $todoItem.priority)
            }
            Section(header: Text("Reminder")) {
                ReminderSectionView(todoItem: $todoItem, insertOrUpdateNotification: $insertOrUpdateNotification)
            }.alert(isPresented: $notificationIsNotAuthorized) {
                Alert(title: Text("You have added a notification but denied notifications for this app. Go to settings to enable notifications."))
            }
        }
        .navigationTitle(Text("Edit task"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    handleDonePressed()
                }
                .disabled(todoItem.title.isEmpty)
            }
        }
        // In SwiftUI we cannot attach 2 alerts at the same place, so one is attached here, and the other to the reminder section
        .alert(isPresented: $showNotificationExpiredDialog) {
            Alert(title: Text("Remove reminder or set a valid reminder date"))
        }
    }

    private struct PrioritySectionView: View {
        @Binding var priority: Int

        var body: some View {
            Picker(selection: $priority, label: Text("Priority")) {
                Text(Priority.low.title).tag(Priority.low.rawValue)
                    .foregroundColor(Priority.low.color)
                Text(Priority.medium.title).tag(Priority.medium.rawValue)
                    .foregroundColor(Priority.medium.color)
                Text(Priority.high.title).tag(Priority.high.rawValue)
                    .foregroundColor(Priority.high.color)
            }
            .labelsHidden() // Some SwiftUI bug prevents the label from being hidden, will hopefully be fixed
        }
    }

    private struct ReminderSectionView: View {
        @Binding var todoItem: TodoListInfo.TodoItem
        @Binding var insertOrUpdateNotification: Bool

        private var dateSelected: Binding<Date> {
            Binding<Date>(
                get: { return todoItem.dueDate.toSwiftDate() },
                set: { date in
                    todoItem.dueDate = todoItem.dueDate.fromSwiftDate(date)
                }
            )
        }

        var body: some View {
            if (todoItem.dueDateIsValid && todoItem.hasNotification) || insertOrUpdateNotification {
                DatePicker("Reminder", selection: dateSelected, in: Date()...).labelsHidden()
            }

            Button((todoItem.dueDateIsValid && todoItem.hasNotification) || insertOrUpdateNotification ? "Remove" : "Set reminder") {
                withAnimation(.easeInOut) {
                    if !todoItem.dueDateIsValid {
                        todoItem.dueDate = todoItem.dueDate.fromSwiftDate(Date()) // Set initial date to the current date
                    }

                    // In case we press remove on an existing notificaiton, reset values to false
                    if (todoItem.hasNotification) {
                        todoItem.hasNotification = false
                        insertOrUpdateNotification = false
                    } else {
                        insertOrUpdateNotification.toggle()
                    }
                }
            }
        }
    }

    private func handleDonePressed() {
        if insertOrUpdateNotification && !todoItem.dueDateIsValid {
            showNotificationExpiredDialog = true
        } else {
            if insertOrUpdateNotification && todoItem.dueDateIsValid {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                        upsertItemAndPopView()
                    } else if settings.authorizationStatus == .notDetermined {
                        requestNotificaitonAuthorization {
                            upsertItemAndPopView()
                        }
                    } else {
                        // The user has previously denied the permission
                        notificationIsNotAuthorized = true
                    }
                }
            } else {
                upsertItemAndPopView()
            }
        }
    }

    private func upsertItemAndPopView() {
        if !todoItem.dueDateIsValid {
            todoItem.hasNotification = false
        } else if insertOrUpdateNotification {
            todoItem.hasNotification = true
        }

        DispatchQueue.main.async {
            viewModel.upsert(editedItem: todoItem)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func requestNotificaitonAuthorization(successHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    successHandler()
                } else if let error = error {
                    print(error.localizedDescription)
                    notificationIsNotAuthorized = true
                }
            }
    }
}

struct AddEditTodoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditTodoView(
                todoItem: TodoListInfo.TodoItem(
                    title: "Medium priority task",
                    description: "Description for medium priority task",
                    priority: Priority.medium.rawValue
                )
            )
        }
    }
}
