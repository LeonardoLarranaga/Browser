//
//  WKWebViewControllerWKScriptMessageHandler.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/24/25.
//

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
        default:
            break
        }
    }
    
    func addHoverURLListener() {
        guard let hoverURLListenerScriptURL = Bundle.main.url(forResource: "HoverURLListener", withExtension: "js"),
              let script = try? String(contentsOf: hoverURLListenerScriptURL, encoding: .utf8) else { return }
        
        let controller = configuration.userContentController

        if weakScriptMessageHandler == nil {
            weakScriptMessageHandler = WeakScriptMessageHandler(handler: self)
        }
        
        controller.removeScriptMessageHandler(forName: "hoverURL")
        controller.add(weakScriptMessageHandler!, name: "hoverURL")

        let scriptMessage = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(scriptMessage)
    }
    
    func handleHoverURL(_ body: Any) {
        guard let url = body as? String, !url.isEmpty else { return }
        self.coordinator.setHoverURL(to: url)
    }
}
