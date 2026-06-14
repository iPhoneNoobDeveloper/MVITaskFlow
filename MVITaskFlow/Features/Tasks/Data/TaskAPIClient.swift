import Foundation

struct TaskAPIClient: Sendable {
    private let endpoint = URL(string: "https://jsonplaceholder.typicode.com/todos")!

    func fetchTasks() async throws -> [TaskItem] {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "_limit", value: "20")]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        try validate(response)
        return try JSONDecoder().decode([RemoteTask].self, from: data).map(\.taskItem)
    }

    func createTask(_ task: TaskItem) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            RemoteTask(userId: 1, id: nil, title: task.title, completed: task.isCompleted)
        )

        let (_, response) = try await URLSession.shared.data(for: request)
        try validate(response)
    }

    func deleteTask(id: UUID) async throws {
        var request = URLRequest(url: endpoint.appendingPathComponent(id.uuidString))
        request.httpMethod = "DELETE"
        let (_, response) = try await URLSession.shared.data(for: request)
        try validate(response)
    }

    private func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode else {
            throw TaskRepositoryError.invalidResponse
        }
    }
}

private struct RemoteTask: Codable, Sendable {
    let userId: Int
    let id: Int?
    let title: String
    let completed: Bool

    var taskItem: TaskItem {
        let suffix = String(format: "%012d", id ?? 0)
        let stableID = UUID(uuidString: "00000000-0000-0000-0000-\(suffix)") ?? UUID()
        return TaskItem(id: stableID, title: title, isCompleted: completed)
    }
}
