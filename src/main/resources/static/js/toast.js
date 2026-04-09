/**
 * toast.js – Lightweight toast notification manager
 */

let _timer = null;

/**
 * Show a toast message
 * @param {string}  msg       - Message to display
 * @param {number}  duration  - Auto-hide delay in ms (default 2500)
 * @param {'info'|'error'|'success'} type
 */
export function toast(msg, duration = 2500, type = 'info') {
    const el = document.getElementById('toast');
    if (!el) return;

    // Reset any running timer
    clearTimeout(_timer);

    el.textContent = msg;
    el.className = 'toast show';

    // Optional type styling hooks
    el.dataset.type = type;

    _timer = setTimeout(() => {
        el.classList.remove('show');
    }, duration);
}