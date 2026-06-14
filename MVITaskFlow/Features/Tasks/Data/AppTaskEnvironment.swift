import Foundation

enum AppTaskEnvironment {
    static func make(arguments: [String] = ProcessInfo.processInfo.arguments) -> TasksFeature.Environment {
        if arguments.contains("--live-data") {
            return TasksFeature.Environment(repository: LiveTaskRepository())
        }

        if arguments.contains("--ui-testing-error") {
            return TasksFeature.Environment(
                repository: MockTaskRepository(tasks: [], fetchError: .unavailable)
            )
        }

        if arguments.contains("--ui-testing-empty") {
            return TasksFeature.Environment(repository: MockTaskRepository(tasks: []))
        }

        return TasksFeature.Environment(repository: MockTaskRepository())
    }
}
