//
//  GetPageText.js
//  Browser
//
//  Created by Leonardo Larrañaga on 3/24/25.
//

function shouldAcceptNode(node) {
    let parent = node.parentNode
    while (parent) {
        const tag = parent.tagName ? parent.tagName.toLowerCase() : ''
        // Skip if node is within a script, style, meta, or other technical tags
        if (['script', 'style', 'meta', 'link', 'noscript'].includes(tag)) {
            return NodeFilter.FILTER_REJECT
        }
        parent = parent.parentNode
    }

    const trimmedText = node.textContent.trim()

    // Skip if text is empty, too short, or looks like HTML/CSS/JS
    if (!trimmedText ||
        trimmedText.length <= 1 ||
        trimmedText.startsWith('<') ||
        trimmedText.includes('{') ||
        trimmedText.includes('}') ||
        /^[\s<>{}\\/]+$/.test(trimmedText)) {
        return NodeFilter.FILTER_REJECT
    }

    return NodeFilter.FILTER_ACCEPT
}

function getText() {
    const texts = []
    const walker = document.createTreeWalker(
        document.body, 
        NodeFilter.SHOW_TEXT, 
        { acceptNode: shouldAcceptNode },
        false
    )

    let node
    while (node = walker.nextNode()) {
        texts.push(node.textContent.trim())
    }

    return texts
}

getText()
