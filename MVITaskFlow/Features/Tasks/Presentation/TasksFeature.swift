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
        
        // Internal intents (Effect -> Store)
        case tasksLoaded([TaskItem])
        case tasksFailed(String)
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
            
            switch intent {
            case .onAppear:
                // Avoid re-loading if we already have data
                guard state.tasks.isEmpty else { return [] }
                state.isloading = true
                state.errorMessage = nil
                
                return [
                    Effect {
                        do {
                            let tasks = try await env.fetchTasks()
                            return .tasksLoaded(tasks)
                        } catch {
                            return .tasksFailed(error.localizedDescription)
                        }
                    }
                ]
                
            case .refresh:
                state.isloading = true
                state.errorMessage = nil
                
                return [
                    Effect {
                        do {
                            let tasks = try await env.fetchTasks()
                            return .tasksLoaded(tasks)
                        } catch {
                            return .tasksFailed(error.localizedDescription)
                        }
                    }
                ]
                
            case .tasksLoaded(let tasks):
                state.isloading = false
                state.tasks = tasks
                return []
                
            case .tasksFailed(let message):
                state.isloading = false
                state.errorMessage = message.isEmpty ? "Something went wrong." : message
                return []
                
            case .draftTitleChanged(let text):
                state.draftTitle = text
                return []
                
            case .addTapped:
                let trimmed = state.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return [] }
                
                // Optimistic UI update
                let newTask = TaskItem(title: trimmed)
                state.tasks.insert(newTask, at: 0)
                state.draftTitle = ""
                
                return [
                    Effect {
                        do {
                            try await env.saveTask(newTask)
                            return nil
                        } catch {
                            return .tasksFailed(error.localizedDescription)
                        }
                    }
                ]
                
            case .toggleCompleted(let id):
                guard let index = state.tasks.firstIndex(where: { $0.id == id }) else { return [] }
                state.tasks[index].isCompleted.toggle()
                return []
                
            case .dismissError:
                state.errorMessage = nil
                return []
            }
            
        }
    }
}
