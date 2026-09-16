//
//  WebPageAutoFill.swift
//  Eva
//

import AppKit
import WebKit

enum WebPageAutoFillAction {
    static let contacts = NSSelectorFromString("_handleInsertFromContactsCommand:")
    static let passwords = NSSelectorFromString("_handleInsertFromPasswordsCommand:")
    static let creditCards = NSSelectorFromString("_handleInsertFromCreditCardsCommand:")

    static let all: Set<Selector> = [contacts, passwords, creditCards]
}

struct WebPageAutoFillElement {
    let inputType: String
    let autocomplete: String
    let name: String
    let identifier: String
    let placeholder: String

    init?(messageBody: Any) {
        guard let body = messageBody as? [String: Any],
              body["focused"] as? Bool == true
        else { return nil }

        inputType = body["type"] as? String ?? "text"
        autocomplete = body["autocomplete"] as? String ?? ""
        name = body["name"] as? String ?? ""
        identifier = body["id"] as? String ?? ""
        placeholder = body["placeholder"] as? String ?? ""
    }

    var contentType: NSTextContentType? {
        let token = autocomplete
            .lowercased()
            .split(separator: " ")
            .last
            .map(String.init)

        switch token {
        case "username": return .username
        case "current-password": return .password
        case "new-password": return .newPassword
        case "one-time-code": return .oneTimeCode
        case "name": return .name
        case "given-name": return .givenName
        case "additional-name": return .middleName
        case "family-name": return .familyName
        case "email": return .emailAddress
        case "tel": return .telephoneNumber
        case "street-address": return .fullStreetAddress
        case "address-line1": return .streetAddressLine1
        case "address-line2": return .streetAddressLine2
        case "address-level2": return .addressCity
        case "address-level1": return .addressState
        case "country", "country-name": return .countryName
        case "postal-code": return .postalCode
        case "cc-name": return .creditCardName
        case "cc-number": return .creditCardNumber
        case "cc-exp": return .creditCardExpiration
        case "cc-exp-month": return .creditCardExpirationMonth
        case "cc-exp-year": return .creditCardExpirationYear
        case "cc-csc": return .creditCardSecurityCode
        case nil, "": break
        default: return nil
        }

        if inputType == "password" {
            return .password
        }

        if inputType == "email" {
            return .username
        }

        let hints = [name, identifier, placeholder]
            .joined(separator: " ")
            .lowercased()

        if ["user", "login", "email", "account", "identifier"].contains(where: hints.contains) {
            return .username
        }

        return nil
    }
}

@MainActor
final class WebPageAutoFillBridge: NSObject, NSTextFieldDelegate {
    private weak var webView: MyWKWebView?
    private let targetIdentifier: String
    private let originalValue: String
    private let textField: NSTextField
    private var expirationWorkItem: DispatchWorkItem?
    private var isFinishing = false

    init(
        webView: MyWKWebView,
        targetIdentifier: String,
        value: String,
        frame: NSRect,
        contentType: NSTextContentType?
    ) {
        self.webView = webView
        self.targetIdentifier = targetIdentifier
        self.originalValue = value

        if contentType == .password || contentType == .newPassword {
            textField = NSSecureTextField(frame: frame)
        } else {
            textField = NSTextField(frame: frame)
        }

        super.init()

        textField.delegate = self
        textField.stringValue = value
        textField.contentType = contentType
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.textColor = .clear
    }

    func present(action: Selector, sender: Any?) {
        guard let webView, let window = webView.window else {
            finish(restoringWebFocus: false)
            return
        }

        webView.addSubview(textField, positioned: .above, relativeTo: nil)

        guard window.makeFirstResponder(textField) else {
            finish(restoringWebFocus: true)
            return
        }

        let expiration = DispatchWorkItem { [weak self] in
            self?.finish(restoringWebFocus: true)
        }
        expirationWorkItem = expiration
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: expiration)

        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let editor = self.textField.currentEditor()
            else {
                self?.finish(restoringWebFocus: true)
                return
            }

            let sent = NSApp.sendAction(action, to: editor, from: sender)

            if !sent {
                self.finish(restoringWebFocus: true)
            }
        }
    }

    func cancel() {
        finish(restoringWebFocus: false)
    }

    func controlTextDidChange(_ notification: Notification) {
        guard textField.stringValue != originalValue else { return }
        commit(textField.stringValue)
    }

    private func commit(_ value: String) {
        guard !isFinishing, let webView else { return }
        isFinishing = true
        expirationWorkItem?.cancel()

        let target = Self.javaScriptLiteral(targetIdentifier)
        let replacement = Self.javaScriptLiteral(value)

        let script = """
        (() => {
            const target = document.querySelector(`[data-eva-autofill-target=${\(target)}]`);
            if (!target) return false;

            const value = \(replacement);
            if (target instanceof HTMLInputElement) {
                const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')?.set;
                setter?.call(target, value);
            } else if (target instanceof HTMLTextAreaElement) {
                const setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')?.set;
                setter?.call(target, value);
            } else {
                target.textContent = value;
            }

            target.dispatchEvent(new InputEvent('input', {
                bubbles: true,
                inputType: 'insertReplacementText'
            }));
            target.dispatchEvent(new Event('change', { bubbles: true }));
            target.removeAttribute('data-eva-autofill-target');
            target.focus({ preventScroll: true });

            if ('selectionStart' in target) {
                target.selectionStart = target.selectionEnd = value.length;
            }

            return true;
        })()
        """

        webView.evaluateJavaScript(script) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.finish(restoringWebFocus: true)
            }
        }
    }

    private func finish(restoringWebFocus: Bool) {
        expirationWorkItem?.cancel()

        if !isFinishing, let webView {
            let target = Self.javaScriptLiteral(targetIdentifier)
            webView.evaluateJavaScript("document.querySelector(`[data-eva-autofill-target=\(target)]`)?.removeAttribute('data-eva-autofill-target')")
        }

        textField.delegate = nil
        textField.stringValue = ""
        textField.removeFromSuperview()

        guard let webView else { return }

        if restoringWebFocus {
            webView.window?.makeFirstResponder(webView)
        }

        webView.autoFillBridge = nil
    }

    private static func javaScriptLiteral(_ value: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed),
              let literal = String(data: data, encoding: .utf8)
        else { return "\"\"" }

        return literal
    }
}

extension MyWKWebView {
    func updateAutoFillFocus(from messageBody: Any) {
        focusedAutoFillElement = WebPageAutoFillElement(messageBody: messageBody)
    }

    func beginWebPageAutoFill(action: Selector, sender: Any?) {
        autoFillBridge?.cancel()

        evaluateJavaScript(Self.autoFillTargetScript) { [weak self] result, _ in
            guard let self,
                  let context = result as? [String: Any],
                  let targetElement = WebPageAutoFillElement(messageBody: context),
                  let targetIdentifier = context["target"] as? String,
                  let value = context["value"] as? String,
                  let x = context["x"] as? Double,
                  let y = context["y"] as? Double,
                  let width = context["width"] as? Double,
                  let height = context["height"] as? Double
            else { return }

            let fieldFrame = NSRect(
                x: x,
                y: self.isFlipped ? y : self.bounds.height - y - height,
                width: max(width, 1),
                height: max(height, 1)
            )

            let bridge = WebPageAutoFillBridge(
                webView: self,
                targetIdentifier: targetIdentifier,
                value: value,
                frame: fieldFrame,
                contentType: targetElement.contentType
            )

            self.autoFillBridge = bridge
            bridge.present(action: action, sender: sender)
        }
    }

    private static let autoFillTargetScript = """
    (() => {
        const target = document.activeElement;
        const supported = target instanceof HTMLInputElement
            || target instanceof HTMLTextAreaElement
            || target?.isContentEditable;

        if (!supported || target.disabled || target.readOnly) return null;

        const identifier = `eva-${crypto.randomUUID()}`;
        target.setAttribute('data-eva-autofill-target', identifier);
        const rect = target.getBoundingClientRect();

        return {
            focused: true,
            target: identifier,
            value: target.value ?? target.textContent ?? '',
            type: target.type ?? (target.isContentEditable ? 'contenteditable' : 'text'),
            autocomplete: target.autocomplete ?? '',
            name: target.name ?? '',
            id: target.id ?? '',
            placeholder: target.placeholder ?? '',
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        };
    })()
    """
}
