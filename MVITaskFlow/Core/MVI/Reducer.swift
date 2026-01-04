//
//  Reducer.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//

public typealias Reducer<State, Intent> = (_ state: inout State, _ intent: Intent) -> [Effect<Intent>]
