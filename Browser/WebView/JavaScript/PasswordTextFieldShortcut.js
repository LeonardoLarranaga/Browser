//
//  PasswordTextFieldShortcut.js
//  Browser
//
//  Created by Leonardo Larrañaga on 4/2/26.
//

// Store single active shortcut
let activeShortcut = null;

function buildShortcut(inputField) {
    const wrapper = document.createElement('div');
    wrapper.style.cssText = `
        position: absolute;
        pointer-events: none;
        z-index: 2147483647;
        top: 0;
        right: 8px;
        height: 100%;
        display: flex;
        align-items: center;
    `;
    
    const shortcutContainer = wrapper.attachShadow({ mode: 'closed' });
    
    shortcutContainer.innerHTML = `
        <style>
            button.show {
                opacity: 1 !important;
            }
        </style>
        <button type="button" style="
            pointer-events: auto;
            width: 24px;
            height: 24px;
            border: none;
            background: #D4D4D480;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            opacity: 0;
        "><span style="display: inline-block; transform: translateX(-3px);">🔑</span></button>
    `;
    
    const button = shortcutContainer.querySelector('button');
    
    button.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        inputField.focus();
        window.webkit?.messageHandlers?.passwordTextFieldShortcut?.postMessage(null);
    });
    
    button.addEventListener('mousedown', (e) => {
        e.preventDefault();
    });
    
    // Insert as sibling to the input field within its parent
    const parent = inputField.parentElement;
    const parentPosition = window.getComputedStyle(parent).position;
    if (parentPosition === 'static') {
        parent.style.position = 'relative';
    }
    
    // Ensure parent doesn't cut off the button
    const parentOverflow = window.getComputedStyle(parent).overflow;
    if (parentOverflow === 'hidden') {
        parent.style.overflow = 'visible';
    }
    
    parent.appendChild(wrapper);
    
    return { wrapper, button };
}

const showShortcut = () => activeShortcut?.button.classList.add('show');
const hideShortcut = () => {
    if (activeShortcut) {
        activeShortcut.button.classList.remove('show');
        activeShortcut.wrapper.remove();
        activeShortcut = null;
    }
};

// Check if input is a valid password/login field
function isValidField(input) {
    if (input.tagName !== 'INPUT' || !input.offsetWidth || !input.offsetHeight) return false;
    if (input.type === 'password' || input.type === 'email') return true;
    if (input.type !== 'text') return false;
    
    const text = [input.name, input.id, input.placeholder, input.autocomplete, input.getAttribute('aria-label')].join(' ').toLowerCase();
    const hasUsernameHint = ['user', 'login', 'email', 'account', 'username', 'userid', 'identifier'].some(h => text.includes(h));
    if (!hasUsernameHint) return false;
    
    const form = input.closest('form');
    if (!form) return !!input.parentElement?.querySelector('input[type="password"]') || true;
    if (form.querySelector('input[type="password"]')) return true;
    
    const formText = [form.action, form.id, form.className].join(' ').toLowerCase();
    return ['login', 'signin', 'sign-in', 'auth', 'account', 'session'].some(h => formText.includes(h));
}

// Handle field interaction (focus or hover)
function handleFieldInteraction(input) {
    if (!isValidField(input)) return;
    
    // If this input already has the active shortcut, do nothing
    if (activeShortcut && activeShortcut.input === input) return;
    
    attachToField(input);
}

// Attach shortcut to an input field
function attachToField(input) {
    // Remove any existing active shortcut
    if (activeShortcut) {
        activeShortcut.wrapper.remove();
        activeShortcut = null;
    }
    
    const { wrapper, button } = buildShortcut(input);
    
    activeShortcut = { input, wrapper, button };
}

// Event delegation for focus and mouseenter on input fields
document.addEventListener('focus', (e) => {
    if (e.target.tagName === 'INPUT') {
        handleFieldInteraction(e.target);
        showShortcut();
    }
}, true);

document.addEventListener('mouseenter', (e) => {
    if (e.target.tagName === 'INPUT') {
        handleFieldInteraction(e.target);
        showShortcut();
    }
}, true);

document.addEventListener('blur', (e) => {
    if (e.target.tagName === 'INPUT' && activeShortcut && activeShortcut.input === e.target) {
        // Delay hiding to allow button clicks
        setTimeout(hideShortcut, 150);
    }
}, true);

document.addEventListener('mouseleave', (e) => {
    if (e.target.tagName === 'INPUT' && activeShortcut && activeShortcut.input === e.target) {
        // Small delay to allow moving to button
        setTimeout(() => {
            // Only hide if not focused
            if (document.activeElement !== activeShortcut?.input) {
                hideShortcut();
            }
        }, 50);
    }
}, true);
