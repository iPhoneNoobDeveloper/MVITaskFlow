import Foundation

actor LiveTaskRepository: TaskRepository {
    private let apiClient: TaskAPIClient
    private let cache: TaskCache

    init(apiClient: TaskAPIClient = TaskAPIClient(), cache: TaskCache = TaskCache()) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchTasks() async throws -> [TaskItem] {
        do {
            let tasks = try await apiClient.fetchTasks()
            try await cache.save(tasks)
            return tasks
        } catch {
            let cachedTasks = try await cache.load()
            guard !cachedTasks.isEmpty else { throw error }
            return cachedTasks
        }
    }

    func saveTask(_ task: TaskItem) async throws {
        try await apiClient.createTask(task)
        try await cache.upsert(task)
    }

    func deleteTask(id: UUID) async throws {
        try await apiClient.deleteTask(id: id)
        try await cache.delete(id: id)
    }
}
