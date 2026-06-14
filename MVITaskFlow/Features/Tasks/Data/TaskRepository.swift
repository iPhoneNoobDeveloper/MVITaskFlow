import Foundation

protocol TaskRepository: Sendable {
    func fetchTasks() async throws -> [TaskItem]
    func saveTask(_ task: TaskItem) async throws
    func deleteTask(id: UUID) async throws
}

enum TaskRepositoryError: LocalizedError, Sendable {
    case invalidResponse
    case unavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The server returned an invalid response."
        case .unavailable:
            "Tasks are temporarily unavailable."
        }
    }
}
