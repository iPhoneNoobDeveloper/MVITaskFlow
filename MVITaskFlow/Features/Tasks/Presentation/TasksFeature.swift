//
//  TasksFeature.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//

import Foundation

struct TasksFeature {
    
    // MARK:- State
    struct TaskState: Equatable, Sendable {
        var tasks: [TaskItem] = []
        var isloading: Bool = false
        var errorMessage: String? = nil
        var draftTitle = ""
    }
    
    // MARK: - Intent (View -> Store)
    enum TaskIntent: Equatable, Sendable {
        case onAppear
        case refresh
        case draftTitleChanged(String)
        case addTapped
        case toggleCompleted(id: UUID)
        case dismissError
    }
    
    // MARK: - Environment (Side effects dependencies)
    struct Environment {
        var fetchTasks: @Sendable () async throws -> [TaskItem]
        var saveTask: @Sendable (TaskItem) async throws -> Void
        
        static let mock: TasksFeature.Environment = (
            Environment(fetchTasks: {
                try await Task.sleep(nanoseconds: 4_000_000_000)
                return [
                    TaskItem(title: "Learn MVI fundamentals"),
                    TaskItem(title: "Build SwiftUI Tasks demo"),
                    TaskItem(title: "Push to GitHub")
                ]
            }, saveTask: { _ in
                try await Task.sleep(nanoseconds: 150_000_000)
            })
        )
    }
    
    // MARK: - Reducer
     static func reducer(env: Environment) -> Reducer<TaskState, TaskIntent> {
         return { state, intent in
             // Step 4 will implement logic + effects.
             return []
         }
     }
}
