import Foundation

actor MockTaskRepository: TaskRepository {
    private var tasks: [TaskItem]
    private let fetchError: TaskRepositoryError?

    init(tasks: [TaskItem] = MockTaskRepository.samples, fetchError: TaskRepositoryError? = nil) {
        self.tasks = tasks
        self.fetchError = fetchError
    }

    func fetchTasks() async throws -> [TaskItem] {
        if let fetchError {
            throw fetchError
        }
        return tasks
    }

    func saveTask(_ task: TaskItem) async throws {
        tasks.insert(task, at: 0)
    }

    func deleteTask(id: UUID) async throws {
        tasks.removeAll { $0.id == id }
    }

    static let samples = [
        TaskItem(title: "Review reducer tests"),
        TaskItem(title: "Document architecture", isCompleted: true),
        TaskItem(title: "Validate offline fallback")
    ]
}
