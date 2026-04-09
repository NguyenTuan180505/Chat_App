/**
 * utils.js – Pure helper functions (no DOM, no state)
 */

/**
 * Escape HTML to prevent XSS
 * @param {string} str
 * @returns {string}
 */
export function esc(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

/**
 * Get initials from a full name
 * @param {string} name
 * @returns {string}
 */
export function initials(name) {
    if (!name) return '?';
    const parts = name.trim().split(/\s+/);
    return parts.length >= 2
        ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
        : name.substring(0, 2).toUpperCase();
}

/**
 * Format ISO timestamp to HH:MM (Vietnamese locale)
 * @param {string|Date} iso
 * @returns {string}
 */
export function formatTime(iso) {
    try {
        const d = new Date(iso);
        if (isNaN(d.getTime())) return '';
        return d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    } catch {
        return '';
    }
}

/**
 * Format date divider label
 * @param {string|Date} iso
 * @returns {string}
 */
export function formatDateLabel(iso) {
    try {
        const d = new Date(iso);
        const now = new Date();
        const isToday = d.toDateString() === now.toDateString();
        if (isToday) return 'Hôm nay';
        const yesterday = new Date(now);
        yesterday.setDate(now.getDate() - 1);
        if (d.toDateString() === yesterday.toDateString()) return 'Hôm qua';
        return d.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' });
    } catch {
        return '';
    }
}

/**
 * Get a user-facing display name for a room.
 * PRIVATE rooms store names like "PRIVATE_<id1>_<id2>".
 * We replace that with the target user's name passed separately.
 *
 * @param {Object} room  - { id, name, type, targetName? }
 * @param {string} myUsername
 * @returns {string}
 */
export function getRoomDisplayName(room, myUsername) {
    if (room.type === 'PRIVATE') {
        // Prefer explicit targetName set when room was created/loaded
        if (room.targetName) return room.targetName;
        // Fallback: strip internal prefix
        return room.name.replace(/^PRIVATE_\d+_\d+$/, 'Chat riêng');
    }
    return room.name;
}

/**
 * Debounce a function call
 * @param {Function} fn
 * @param {number} ms
 * @returns {Function}
 */
export function debounce(fn, ms) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => fn(...args), ms);
    };
}