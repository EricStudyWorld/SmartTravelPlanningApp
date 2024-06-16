//
//  TaskData.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import SwiftUI
import RealmSwift

class TaskData: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var taskTitle: String
    @Persisted var creationDate: Date = Date()
    @Persisted var isCompleted = false
    @Persisted var tint: String = "TaskColor 1"
    @Persisted var selectedPlace: Place?
    @Persisted var taskExpense: Float

    var tintColor: Color {
        switch tint {
        case "TaskColor 1": return .taskColor1
        case "TaskColor 2": return .taskColor2
        default: return .black
        }
    }

    convenience init(taskTitle: String, creationDate: Date = Date(), tint: String, selectedPlace: Place? = nil) {
        self.init()
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.tint = tint
        self.selectedPlace = selectedPlace
    }

    func convertedExpense(to currency: String, with rate: Double) -> Float {
        return taskExpense * Float(rate)
    }
}

extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}
