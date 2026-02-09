//
//  WKWebViewControllerWKScriptMessageHandler.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/24/25.
//

import WebKit

extension WKWebViewController: WKScriptMessageHandler {

    /// A wrapper that holds a weak reference to a WKScriptMessageHandler
    /// This prevents retain cycles when adding script message handlers to WKUserContentController
    class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
        weak var handler: WKScriptMessageHandler?

        init(handler: WKScriptMessageHandler) {
            self.handler = handler
            super.init()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            handler?.userContentController(userContentController, didReceive: message)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "hoverURL":
            handleHoverURL(message.body)
        case "passwordTextFieldShortcut":
            handlePasswordTextFieldShortcut(message.body)
        default:
            break
        }
    }

    // MARK: - Generic Script Management

    /// Adds a user script with a message handler
    /// - Parameters:
    ///   - scriptName: The name of the JavaScript file (without .js extension)
    ///   - handlerName: The name of the message handler
    ///   - injectionTime: When to inject the script (default: .atDocumentEnd)
    func addUserScript(_ scriptName: String, handlerName: String, injectionTime: WKUserScriptInjectionTime = .atDocumentEnd) {
        guard let scriptSource = JavaScript.getBundled(scriptName) else { return }

        let controller = configuration.userContentController

        if weakScriptMessageHandler == nil {
            weakScriptMessageHandler = WeakScriptMessageHandler(handler: self)
        }

        controller.removeScriptMessageHandler(forName: handlerName)
        controller.add(weakScriptMessageHandler!, name: handlerName)

        let script = WKUserScript(source: scriptSource, injectionTime: injectionTime, forMainFrameOnly: true)
        controller.addUserScript(script)
    }

    /// Removes a user script and its message handler
    /// - Parameter handlerName: The name of the message handler to remove
    func removeUserScript(handlerName: String) {
        let controller = configuration.userContentController
        controller.removeScriptMessageHandler(forName: handlerName)
    }

    // MARK: - Specific Script Handlers

    func addHoverURLListener() {
        addUserScript("HoverURLListener", handlerName: "hoverURL")
    }

    func addPasswordTextFieldShortcut() {
        addUserScript("PasswordTextFieldShortcut", handlerName: "passwordTextFieldShortcut")
    }

    // MARK: - Message Handlers

    func handleHoverURL(_ body: Any) {
        guard let url = body as? String, !url.isEmpty else { return }
        self.coordinator.setHoverURL(to: url)
    }

    func handlePasswordTextFieldShortcut(_ body: Any) {
        guard let appURL = Preferences.shared.selectedPasswordApp else { return }
        NSWorkspace.shared.open(appURL)
    }
}
