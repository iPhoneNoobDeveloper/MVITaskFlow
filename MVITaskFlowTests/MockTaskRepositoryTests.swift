import XCTest
@testable import MVITaskFlow

final class MockTaskRepositoryTests: XCTestCase {

    func testFetchReturnsSeededTasks() async throws {
        let seeded = [TaskItem(title: "One"), TaskItem(title: "Two")]
        let repository = MockTaskRepository(tasks: seeded)

        let fetched = try await repository.fetchTasks()

        XCTAssertEqual(fetched, seeded)
    }

    func testSaveTaskAddsTaskAtFront() async throws {
        let existing = TaskItem(title: "Existing")
        let repository = MockTaskRepository(tasks: [existing])
        let inserted = TaskItem(title: "Inserted")

        try await repository.saveTask(inserted)

        let fetched = try await repository.fetchTasks()
        XCTAssertEqual(fetched.first, inserted)
        XCTAssertEqual(fetched.count, 2)
    }

    func testDeleteTaskRemovesMatchingTask() async throws {
        let kept = TaskItem(title: "Keep")
        let removed = TaskItem(title: "Remove")
        let repository = MockTaskRepository(tasks: [kept, removed])

        try await repository.deleteTask(id: removed.id)

        let fetched = try await repository.fetchTasks()
        XCTAssertEqual(fetched, [kept])
    }

    func testFetchThrowsConfiguredError() async {
        let repository = MockTaskRepository(tasks: [], fetchError: .unavailable)

        do {
            _ = try await repository.fetchTasks()
            XCTFail("Expected repository fetch to throw")
        } catch {
            XCTAssertEqual(error.localizedDescription, TaskRepositoryError.unavailable.localizedDescription)
        }
    }
}
