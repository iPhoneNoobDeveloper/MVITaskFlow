//
//  TasksFeatureReducerTests.swift
//  MVITaskFlowTests
//
//  Created by Nirav Jain on 1/4/26.
//

import Testing
import XCTest
@testable import MVITaskFlow

final class TasksFeatureReducerTests: XCTestCase {

    func testDraftTitleChanged_updatesDraftTitle() {
        var state = TasksFeature.TaskState()
        let reducer = TasksFeature.reducer(env: .mock)

        _ = reducer(&state, .draftTitleChanged("Buy milk"))

        XCTAssertEqual(state.draftTitle, "Buy milk")
    }

    func testAddTapped_insertsTaskAndClearsDraft() {
        var state = TasksFeature.TaskState(tasks: [], isLoading: false, errorMessage: nil, draftTitle: "Buy milk")
        let reducer = TasksFeature.reducer(env: .mock)

        _ = reducer(&state, .addTapped)

        XCTAssertEqual(state.draftTitle, "")
        XCTAssertEqual(state.tasks.count, 1)
        XCTAssertEqual(state.tasks.first?.title, "Buy milk")
        XCTAssertEqual(state.tasks.first?.isCompleted, false)
    }

    func testToggleCompleted_togglesMatchingTask() {
        let id = UUID()
        var state = TasksFeature.TaskState(
            tasks: [TaskItem(id: id, title: "Test", isCompleted: false)],
            isLoading: false,
            errorMessage: nil,
            draftTitle: ""
        )
        let reducer = TasksFeature.reducer(env: .mock)

        _ = reducer(&state, .toggleCompleted(id: id))

        XCTAssertEqual(state.tasks[0].isCompleted, true)
    }

    func testDelete_removesTask() {
        let id = UUID()
        var state = TasksFeature.TaskState(
            tasks: [TaskItem(id: id, title: "To delete", isCompleted: false)],
            isLoading: false,
            errorMessage: nil,
            draftTitle: ""
        )

        let env = TasksFeature.Environment(
            fetchTasks: { [] },
            saveTask: { _ in },
            deleteTask: { _ in }
        )
        let reducer = TasksFeature.reducer(env: env)

        let effects = reducer(&state, .delete(id: id))

        XCTAssertEqual(state.tasks.count, 0)
        XCTAssertEqual(effects.count, 1) // delete effect fired
    }

    func testRefresh_setsLoadingAndReturnsEffect() {
        var state = TasksFeature.TaskState()
        let reducer = TasksFeature.reducer(env: .mock)

        let effects = reducer(&state, .refresh)

        XCTAssertTrue(state.isLoading)
        XCTAssertEqual(effects.count, 1)
    }

    func testTasksFailed_stopsLoadingAndStoresMessage() {
        var state = TasksFeature.TaskState(isLoading: true)
        let reducer = TasksFeature.reducer(env: .mock)

        _ = reducer(&state, .tasksFailed("Offline"))

        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.errorMessage, "Offline")
    }

    func testDismissError_clearsMessage() {
        var state = TasksFeature.TaskState(errorMessage: "Offline")
        let reducer = TasksFeature.reducer(env: .mock)

        _ = reducer(&state, .dismissError)

        XCTAssertNil(state.errorMessage)
    }
}
