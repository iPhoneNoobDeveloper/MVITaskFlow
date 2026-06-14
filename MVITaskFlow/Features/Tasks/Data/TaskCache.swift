import Foundation

actor TaskCache {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        fileURL = directory.appendingPathComponent("tasks-cache.json")
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() throws -> [TaskItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([TaskItem].self, from: data)
    }

    func save(_ tasks: [TaskItem]) throws {
        let data = try JSONEncoder().encode(tasks)
        try data.write(to: fileURL, options: .atomic)
    }

    func upsert(_ task: TaskItem) throws {
        var tasks = try load()
        tasks.removeAll { $0.id == task.id }
        tasks.insert(task, at: 0)
        try save(tasks)
    }

    func delete(id: UUID) throws {
        var tasks = try load()
        tasks.removeAll { $0.id == id }
        try save(tasks)
    }
}
