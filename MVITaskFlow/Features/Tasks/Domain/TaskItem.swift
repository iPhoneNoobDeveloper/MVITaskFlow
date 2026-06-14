//
//  TaskItem.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//

import Foundation

public struct TaskItem: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
