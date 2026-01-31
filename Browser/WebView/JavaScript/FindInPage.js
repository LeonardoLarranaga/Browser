//
//  FindInPage.js
//  Browser
//
//  Created by Leonardo Larrañaga on 30/1/26.
//

(function() {
    'use strict';

    // Namespace to avoid conflicts
    window.BrowserFindInPage = window.BrowserFindInPage || {};

    const HIGHLIGHT_CLASS = 'browser-find-highlight';
    const CURRENT_HIGHLIGHT_CLASS = 'browser-find-highlight-current';
    const STYLE_ID = 'browser-find-in-page-styles';

    // State
    let matches = [];
    let currentMatchIndex = -1;
    let lastSearchQuery = '';

    // Inject styles for highlights
    function injectStyles() {
        if (document.getElementById(STYLE_ID)) return;

        const style = document.createElement('style');
        style.id = STYLE_ID;
        style.textContent = `
            .${HIGHLIGHT_CLASS} {
                background-color: rgba(255, 255, 0, 0.5) !important;
                border-radius: 2px !important;
                box-shadow: 0 0 0 1px rgba(255, 220, 0, 0.4), 0 1px 3px rgba(0, 0, 0, 0.15) !important;
                padding: 1px 0 !important;
            }
            .${CURRENT_HIGHLIGHT_CLASS} {
                background-color: rgba(255, 230, 0, 0.85) !important;
                box-shadow: 0 0 0 2px rgba(255, 200, 0, 0.7), 0 0 8px 2px rgba(255, 230, 0, 0.6), 0 2px 4px rgba(0, 0, 0, 0.2) !important;
            }
        `;
        document.head.appendChild(style);
    }

    // Remove all highlights
    function clearHighlights() {
        const highlights = document.querySelectorAll(`.${HIGHLIGHT_CLASS}`);
        highlights.forEach(highlight => {
            const parent = highlight.parentNode;
            while (highlight.firstChild) {
                parent.insertBefore(highlight.firstChild, highlight);
            }
            parent.removeChild(highlight);
            parent.normalize(); // Merge adjacent text nodes
        });
        matches = [];
        currentMatchIndex = -1;
    }

    // Check if an element is visible
    function isElementVisible(element) {
        if (!element) return false;

        // Check if element or any parent is hidden
        let current = element;
        while (current && current !== document.body) {
            const style = window.getComputedStyle(current);

            // Check for display: none
            if (style.display === 'none') return false;

            // Check for visibility: hidden
            if (style.visibility === 'hidden') return false;

            // Check for opacity: 0
            if (style.opacity === '0') return false;

            // Check for zero dimensions (but allow inline elements)
            const rect = current.getBoundingClientRect();
            if (rect.width === 0 && rect.height === 0 && style.display !== 'inline') {
                return false;
            }

            current = current.parentElement;
        }

        return true;
    }

    // Check if a node should be searched
    function isSearchableNode(node) {
        if (!node.parentNode) return false;

        let parent = node.parentNode;
        while (parent) {
            const tag = parent.tagName ? parent.tagName.toLowerCase() : '';
            if (['script', 'style', 'meta', 'link', 'noscript', 'iframe', 'textarea', 'input', 'head'].includes(tag)) {
                return false;
            }
            // Skip if parent is already a highlight
            if (parent.classList && parent.classList.contains(HIGHLIGHT_CLASS)) {
                return false;
            }
            parent = parent.parentNode;
        }

        const text = node.textContent;
        if (!text || text.trim().length === 0) return false;

        // Check if the parent element is visible
        if (!isElementVisible(node.parentElement)) return false;

        return true;
    }

    // Find all text nodes in the document
    function getTextNodes() {
        const textNodes = [];
        const walker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            {
                acceptNode: function(node) {
                    return isSearchableNode(node) ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
                }
            }
        );

        let node;
        while (node = walker.nextNode()) {
            textNodes.push(node);
        }
        return textNodes;
    }

    // Highlight matches in a text node
    function highlightMatches(textNode, query) {
        const text = textNode.textContent;
        const lowerText = text.toLowerCase();
        const lowerQuery = query.toLowerCase();

        let lastIndex = 0;
        let index = lowerText.indexOf(lowerQuery, lastIndex);

        if (index === -1) return [];

        const fragment = document.createDocumentFragment();
        const nodeMatches = [];

        while (index !== -1) {
            // Add text before match
            if (index > lastIndex) {
                fragment.appendChild(document.createTextNode(text.substring(lastIndex, index)));
            }

            // Create highlight span
            const highlight = document.createElement('span');
            highlight.className = HIGHLIGHT_CLASS;
            highlight.textContent = text.substring(index, index + query.length);
            fragment.appendChild(highlight);
            nodeMatches.push(highlight);

            lastIndex = index + query.length;
            index = lowerText.indexOf(lowerQuery, lastIndex);
        }

        // Add remaining text
        if (lastIndex < text.length) {
            fragment.appendChild(document.createTextNode(text.substring(lastIndex)));
        }

        // Replace original node with fragment
        textNode.parentNode.replaceChild(fragment, textNode);

        return nodeMatches;
    }

    // Compare two elements by their visual position (top to bottom, left to right)
    function compareElementPositions(a, b) {
        const rectA = a.getBoundingClientRect();
        const rectB = b.getBoundingClientRect();

        // Compare by vertical position first (top)
        if (Math.abs(rectA.top - rectB.top) > 5) {
            return rectA.top - rectB.top;
        }

        // If on the same line, compare by horizontal position (left)
        return rectA.left - rectB.left;
    }

    // Sort matches by visual position on the page
    function sortMatchesByPosition() {
        matches.sort(compareElementPositions);
    }

    // Perform the search
    function search(query) {
        injectStyles();
        clearHighlights();

        if (!query || query.trim().length === 0) {
            lastSearchQuery = '';
            return { totalMatches: 0, currentMatch: 0 };
        }

        lastSearchQuery = query;
        const textNodes = getTextNodes();

        textNodes.forEach(textNode => {
            const nodeMatches = highlightMatches(textNode, query);
            matches.push(...nodeMatches);
        });

        // Sort matches by visual position (top to bottom, left to right)
        sortMatchesByPosition();

        if (matches.length > 0) {
            currentMatchIndex = 0;
            updateCurrentHighlight();
            scrollToCurrentMatch();
        }

        return {
            totalMatches: matches.length,
            currentMatch: matches.length > 0 ? 1 : 0
        };
    }

    // Update which match is currently highlighted
    function updateCurrentHighlight() {
        matches.forEach((match, index) => {
            if (index === currentMatchIndex) {
                match.classList.add(CURRENT_HIGHLIGHT_CLASS);
            } else {
                match.classList.remove(CURRENT_HIGHLIGHT_CLASS);
            }
        });
    }

    // Scroll to the current match
    function scrollToCurrentMatch() {
        if (currentMatchIndex >= 0 && currentMatchIndex < matches.length) {
            const match = matches[currentMatchIndex];
            match.scrollIntoView({
                behavior: 'smooth',
                block: 'center',
                inline: 'nearest'
            });
        }
    }

    // Go to next match
    function goToNextMatch() {
        if (matches.length === 0) return { totalMatches: 0, currentMatch: 0 };

        currentMatchIndex = (currentMatchIndex + 1) % matches.length;
        updateCurrentHighlight();
        scrollToCurrentMatch();

        return {
            totalMatches: matches.length,
            currentMatch: currentMatchIndex + 1
        };
    }

    // Go to previous match
    function goToPreviousMatch() {
        if (matches.length === 0) return { totalMatches: 0, currentMatch: 0 };

        currentMatchIndex = (currentMatchIndex - 1 + matches.length) % matches.length;
        updateCurrentHighlight();
        scrollToCurrentMatch();

        return {
            totalMatches: matches.length,
            currentMatch: currentMatchIndex + 1
        };
    }

    // Get current state
    function getState() {
        return {
            totalMatches: matches.length,
            currentMatch: matches.length > 0 ? currentMatchIndex + 1 : 0,
            query: lastSearchQuery
        };
    }

    // Clear everything
    function clear() {
        clearHighlights();
        lastSearchQuery = '';
        return { totalMatches: 0, currentMatch: 0 };
    }

    // Expose API
    window.BrowserFindInPage = {
        search: search,
        goToNextMatch: goToNextMatch,
        goToPreviousMatch: goToPreviousMatch,
        getState: getState,
        clear: clear
    };

    return window.BrowserFindInPage;
})();
