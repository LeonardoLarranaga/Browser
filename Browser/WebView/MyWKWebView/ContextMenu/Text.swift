//
//  ContextMenuText.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import WebKit

extension MyWKWebView {
    /// Creates the custom menu for text
    /// - Parameter menu: The context menu to modify
    func handleTextContextMenu(_ menu: NSMenu) {
        // Remove WKMenuItemIdentifierSearchWeb
        menu.items.remove(at: 2)
        
        let searchWebItem = NSMenuItem(title: "Search With Google", action: #selector(searchWeb), keyEquivalent: "")
        menu.insertItem(searchWebItem, at: 2)
    }
    
    @objc func searchWeb() {
        getSelectedText { selectedText in
            if let selectedText {
                self.searchWebAction?(selectedText)
            }
        }
    }
    
    func getSelectedText(completion: @escaping (String?) -> Void) {
        evaluateJavaScript("window.getSelection().toString()") { result, error in
            if let error {
                print("Error getting selected text: \(error)")
                completion(nil)
            } else if let selectedText = result as? String {
                completion(selectedText)
            } else {
                completion(nil)
            }
        }
    }
}
