# MVITaskFlow (SwiftUI MVI Demo)

A small SwiftUI app demonstrating **MVI (Model–View–Intent)** with **unidirectional data flow**,
predictable state management, and testable side effects.

## What this repo shows

- **Single source of truth**: `State` drives UI rendering
- **Explicit user events**: `Intent` captures UI + lifecycle actions
- **Pure state transitions**: `Reducer` mutates state synchronously
- **Side effects**: `Effect` runs async work and feeds results back as intents
- **Testability**: reducer and effects are unit-tested

## Architecture overview

Each feature owns its domain types:

- `TasksFeature.State` — UI state rendered by SwiftUI
- `TasksFeature.Intent` — events from the View + internal events from effects
- `TasksFeature.Environment` — dependencies for side effects (fetch/save/delete)
- `TasksFeature.reducer(env:)` — business rules + effect creation

Core MVI runtime is reusable across features:

- `Store<State, Intent>` — holds state, accepts intents, runs reducer, executes effects
- `Reducer<State, Intent>` — `(inout State, Intent) -> [Effect<Intent>]`
- `Effect<Intent>` — async operation returning the next intent

### Unidirectional flow

```text
User / View Events
      |
      v
Intent  ------------------------------+
      |                              |
      v                              |
Reducer (sync) -> State (updated)    |
      |                              |
      +--> Effects (async) ----------+
              |
              v
        Intent (result)

Project structure

Core/MVI
  - Store.swift
  - Reducer.swift
  - Effect.swift

Features/Tasks
  - Domain/TaskItem.swift
  - Presentation/TasksFeature.swift
  - Presentation/TasksView.swift

