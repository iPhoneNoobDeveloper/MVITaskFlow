import XCTest
@testable import MVITaskFlow

final class TaskCacheTests: XCTestCase {

    func testSaveAndLoadRoundTripsTasks() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let cache = TaskCache(fileURL: fileURL)
        let expected = [
            TaskItem(title: "Cache A"),
            TaskItem(title: "Cache B", isCompleted: true)
        ]

        try await cache.save(expected)

        let loaded = try await cache.load()
        XCTAssertEqual(loaded, expected)
    }

    func testUpsertReplacesExistingTask() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let cache = TaskCache(fileURL: fileURL)
        let id = UUID()

        try await cache.save([TaskItem(id: id, title: "Original")])
        try await cache.upsert(TaskItem(id: id, title: "Updated", isCompleted: true))

        let loaded = try await cache.load()
        XCTAssertEqual(loaded, [TaskItem(id: id, title: "Updated", isCompleted: true)])
    }

    func testDeleteRemovesMatchingTask() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let cache = TaskCache(fileURL: fileURL)
        let kept = TaskItem(title: "Keep")
        let removed = TaskItem(title: "Remove")

        try await cache.save([kept, removed])
        try await cache.delete(id: removed.id)

        let loaded = try await cache.load()
        XCTAssertEqual(loaded, [kept])
    }
}
