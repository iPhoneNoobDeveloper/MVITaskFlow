//
//  TasksFeatureEffectsTests.swift
//  MVITaskFlowTests
//
//  Created by Nirav Jain on 1/4/26.
//

import XCTest
@testable import MVITaskFlow

final class TasksFeatureEffectsTests: XCTestCase {

    func testRefreshEffect_emitsTasksLoaded() async {
        let expected = [
            TaskItem(title: "A"),
            TaskItem(title: "B")
        ]

        let env = TasksFeature.Environment(
            fetchTasks: { expected },
            saveTask: { _ in },
            deleteTask: { _ in }
        )

        var state = TasksFeature.TaskState()
        let reducer = TasksFeature.reducer(env: env)

        let effects = reducer(&state, .refresh)
        XCTAssertEqual(effects.count, 1)

        let emitted = await effects[0].run()
        XCTAssertEqual(emitted, .tasksLoaded(expected))
    }

    func testRefreshEffect_emitsTasksFailed_onError() async {
        struct DummyError: LocalizedError {
            var errorDescription: String? { "Boom" }
        }

        let env = TasksFeature.Environment(
            fetchTasks: { throw DummyError() },
            saveTask: { _ in },
            deleteTask: { _ in }
        )

        var state = TasksFeature.TaskState()
        let reducer = TasksFeature.reducer(env: env)

        let effects = reducer(&state, .refresh)
        let emitted = await effects[0].run()

        XCTAssertEqual(emitted, .tasksFailed("Boom"))
    }
}
