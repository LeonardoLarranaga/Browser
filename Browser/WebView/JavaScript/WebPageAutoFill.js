(() => {
    if (window.__evaWebPageAutoFillInstalled) return;
    window.__evaWebPageAutoFillInstalled = true;

    const inputTypes = new Set(['text', 'password', 'email', 'tel', 'url', 'search', 'number']);

    const isSupported = (element) => {
        if (!element) return false;
        if (element instanceof HTMLInputElement || element instanceof HTMLTextAreaElement) {
            return inputTypes.has(element.type) && !element.disabled && !element.readOnly;
        }
        return element.isContentEditable;
    };

    const reportFocus = () => {
        const element = document.activeElement;

        if (!isSupported(element)) {
            window.webkit.messageHandlers.webPageAutoFill.postMessage({ focused: false });
            return;
        }

        window.webkit.messageHandlers.webPageAutoFill.postMessage({
            focused: true,
            type: element.type ?? (element.isContentEditable ? 'contenteditable' : 'text'),
            autocomplete: element.autocomplete ?? '',
            name: element.name ?? '',
            id: element.id ?? '',
            placeholder: element.placeholder ?? ''
        });
    };

    document.addEventListener('contextmenu', (event) => {
        const element = event.target instanceof Element
            ? event.target.closest('input, textarea, [contenteditable]')
            : null;

        if (isSupported(element)) {
            element.focus({ preventScroll: true });
            reportFocus();
        }
    }, true);

    document.addEventListener('focusin', reportFocus, true);
    document.addEventListener('focusout', () => setTimeout(reportFocus, 0), true);
    reportFocus();
})();
