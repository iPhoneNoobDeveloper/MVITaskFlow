    //
//  Effect.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//

public struct Effect<Intent>: Sendable {
    public let operation: @Sendable () async -> Intent?

    public init(operation: @escaping @Sendable () async -> Intent?) {
        self.operation = operation
    }

    public static var none: [Effect] { [] }
}
