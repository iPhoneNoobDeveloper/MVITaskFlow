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
                addBar
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.refresh)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh")
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
    
    // MARK: - Subviews
    
    private var addBar: some View {
        HStack(spacing: 8) {
            TextField("New task", text: Binding(
                get: { store.state.draftTitle },
                set: { store.send(.draftTitleChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .onSubmit { store.send(.addTapped) }
            
            Button {
                store.send(.addTapped)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .accessibilityLabel("Add task")
            .disabled(store.state.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var content: some View {
        if store.state.isLoading && store.state.tasks.isEmpty {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading tasks…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        } else if store.state.tasks.isEmpty {
            ContentUnavailableView(
                "No tasks yet",
                systemImage: "checklist",
                description: Text("Add a task above or pull to refresh.")
            )
            .padding(.top, 12)
            
        } else {
            List {
                ForEach(store.state.tasks) { task in
                    taskRow(task)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                store.send(.toggleCompleted(id: task.id))
                            } label: {
                                Label(
                                    task.isCompleted ? "Mark incomplete" : "Mark complete",
                                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.delete(id: task.id))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable { store.send(.refresh) }
        }
    }
    
    private func taskRow(_ task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .imageScale(.large)
                .accessibilityHidden(true)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { store.send(.toggleCompleted(id: task.id)) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
    }
}

#Preview {
    TasksView()
}
