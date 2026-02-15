//
//  TabUndoManager.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 14/2/26.
//

import SwiftUI

/// Manages undo/redo stack for tab close operations
@Observable
final class TabUndoManager {
    private var undoStack: [UndoableCommand] = []
    private var redoStack: [UndoableCommand] = []

    private let maxStackSize = 20

    weak var browserWindow: BrowserWindow?

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    var undoDescription: String {
        "Undo " + (undoStack.last?.description ?? "Close Tab")
    }
    var redoDescription: String {
        "Redo " + (redoStack.last?.description ?? "Close Tab")
    }

    func execute(_ command: UndoableCommand) {
        command.execute()
        undoStack.append(command)
        // Clear redo stack on new command
        redoStack.removeAll()

        // Limit stack size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
    }

    func undo() {
        let message = undoDescription
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
        browserWindow?.presentActionAlert(message: message, systemImage: "arrow.uturn.backward")
    }

    func redo() {
        let message = redoDescription
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
        browserWindow?.presentActionAlert(message: message, systemImage: "arrow.uturn.forward")
    }
}
