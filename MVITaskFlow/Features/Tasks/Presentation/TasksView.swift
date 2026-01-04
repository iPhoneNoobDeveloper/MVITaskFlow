//
//  TasksView.swift
//  MVITaskFlow
//
//  Created by Nirav Jain on 1/3/26.
//

import SwiftUI

struct TasksView: View {
    
    @StateObject private var store = Store(state: TasksFeature.TaskState(), reducer: TasksFeature.reducer(env: .mock))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    
                    TextField("New task", text: Binding(
                        get: { store.state.draftTitle },
                        set: { store.send(.draftTitleChanged($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                    
                    Button("Add") {
                        store.send(.addTapped)
                    }
                    .disabled(store.state.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                }
                .padding(.horizontal)
                
                List {
                    ForEach(store.state.tasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(task.title)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.send(.toggleCompleted(id: task.id))
                        }

                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") { store.send(.refresh) }
                }
            }
            .onAppear { store.send(.onAppear) }
            .alert("Error", isPresented: Binding(
                get: { store.state.errorMessage != nil },
                set: { isPresented in
                    if !isPresented { store.send(.dismissError) }
                }
            )) {
                Button("OK") { store.send(.dismissError) }
            } message: {
                Text(store.state.errorMessage ?? "")
            }
            
        }
    }
}

#Preview {
    TasksView()
}
