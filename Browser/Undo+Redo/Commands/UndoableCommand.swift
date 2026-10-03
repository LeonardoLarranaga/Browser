//
//  TabCloseCommand.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 14/2/26.
//

/// Protocol for a command that can be executed and undone, specifically for closing tabs in the browser.
/// This allows for implementing undo/redo functionality for tab closures.
protocol UndoableCommand {
    func execute()
    func undo()
    var description: LocalizedStringResource { get }
}
