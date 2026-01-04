    //
//  Store.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//
import Foundation
public import Combine

@MainActor
public final class Store<State, Intent>: ObservableObject {
    @Published public private(set) var state: State
    private let reducer : Reducer<State,Intent>
    
    init(state: State, reducer: @escaping Reducer<State, Intent>) {
        self.state = state
        self.reducer = reducer
    }
    
    public func send(_ intent: Intent) {
        let effects = self.reducer(&self.state, intent)
        run(effects)
    }
    
    private func run(_ effects: [Effect<Intent>]) {
        for effect in effects {
            Task { [weak self] in
                guard let self else { return }
                if let next = await effect.operation() {
                    await self.send(next)
                }
            }
        }
    }
}
