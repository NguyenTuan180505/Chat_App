/**
 * ui.js – DOM rendering helpers for the chat interface
 *
 * No business logic here – only rendering / DOM manipulation.
 */

import { esc, initials, formatTime, formatDateLabel, getRoomDisplayName } from './utils.js';

// ── SIDEBAR ───────────────────────────────────────────────────────────────────

/**
 * Build a sidebar room list item element.
 * @param {Object}   room          - { id, name, type, targetName? }
 * @param {string}   myUsername    - current user's username
 * @param {Function} onClickRoom   - callback(room)
 * @returns {HTMLElement}
 */
export function buildRoomItem(room, myUsername, onClickRoom) {
    const div = document.createElement('div');
    div.className = 'room-item';
    div.id = `ri-${room.id}`;

    const displayName = getRoomDisplayName(room, myUsername);
    const isPrivate   = room.type === 'PRIVATE';

    div.innerHTML = `
        <div class="room-icon ${isPrivate ? 'private' : 'group'}">
            ${isPrivate ? '👤' : '#'}
        </div>
        <div class="room-info">
            <div class="rname" title="${esc(displayName)}">${esc(displayName)}</div>
            <div class="rtype">${isPrivate ? 'Riêng tư' : 'Nhóm'}</div>
        </div>`;

    div.addEventListener('click', () => onClickRoom(room));
    return div;
}

/**
 * Mark a room item as active (selected) in the sidebar.
 * @param {number|string} roomId
 */
export function setActiveRoom(roomId) {
    document.querySelectorAll('.room-item').forEach(el => el.classList.remove('active'));
    const el = document.getElementById(`ri-${roomId}`);
    if (el) el.classList.add('active');
}

/**
 * Populate both group and private sidebar lists.
 * @param {Array}    rooms        - Array of room objects
 * @param {string}   myUsername
 * @param {Function} onClickRoom  - callback(room)
 */
export function renderRoomLists(rooms, myUsername, onClickRoom) {
    const gList = document.getElementById('groupRoomList');
    const pList = document.getElementById('privateRoomList');
    gList.innerHTML = '';
    pList.innerHTML = '';

    rooms.forEach(room => {
        const el = buildRoomItem(room, myUsername, onClickRoom);
        if (room.type === 'GROUP') gList.appendChild(el);
        else                       pList.appendChild(el);
    });
}

// ── CHAT HEADER ────────────────────────────────────────────────────────────────

/**
 * Show the chat area and update the header for the selected room.
 * @param {Object} room        - { id, name, type, targetName? }
 * @param {string} myUsername
 */
export function showChatArea(room, myUsername) {
    document.getElementById('emptyState').style.display   = 'none';
    document.getElementById('chatHeader').style.display   = 'flex';
    document.getElementById('messagesWrap').style.display = 'flex';
    document.getElementById('inputArea').style.display    = 'flex';

    const isPrivate   = room.type === 'PRIVATE';
    const displayName = getRoomDisplayName(room, myUsername);

    const av = document.getElementById('chatAvatar');
    av.textContent   = isPrivate ? '👤' : '#';
    av.style.background = isPrivate ? '#dcfce7' : '#eff6ff';
    av.style.fontSize   = '18px';

    document.getElementById('chatTitle').textContent = displayName;
    document.getElementById('chatSub').textContent   =
        isPrivate ? 'Trò chuyện riêng tư' : 'Phòng nhóm';
}

// ── MESSAGES ───────────────────────────────────────────────────────────────────

/**
 * Clear the message area and show the empty placeholder.
 */
export function clearMessages() {
    document.getElementById('messagesWrap').innerHTML = '';
}

/**
 * Show "no messages yet" placeholder inside the message area.
 */
export function showNoMessages() {
    const wrap = document.getElementById('messagesWrap');
    wrap.innerHTML = `
        <div class="no-msg-placeholder" style="text-align:center;margin:auto;">
            <div style="font-size:40px;margin-bottom:8px;">🗨️</div>
            <p style="font-size:14px;color:var(--text2);">Chưa có tin nhắn nào. Hãy bắt đầu trò chuyện!</p>
        </div>`;
}

/**
 * Append a single message bubble to the message area.
 *
 * @param {Object}  msg
 * @param {string}  msg.senderUsername  - username of sender
 * @param {string}  msg.senderName      - display name of sender
 * @param {string}  msg.content         - message text
 * @param {string}  msg.createdAt       - ISO timestamp
 * @param {boolean} [msg._isMe]         - optimistic-UI flag
 * @param {string}  myUsername          - current user's username
 */
export function appendMessage(msg, myUsername) {
    const wrap = document.getElementById('messagesWrap');

    // Remove the "no messages" placeholder if present
    const placeholder = wrap.querySelector('.no-msg-placeholder');
    if (placeholder) placeholder.remove();

    // Determine ownership
    // BUG FIX: the original code compared msg.senderId (a DB Long) with ME (a string username).
    // We now compare senderUsername exclusively.
    const isMe       = msg._isMe === true || msg.senderUsername === myUsername;
    const senderName = msg.senderName || msg.senderUsername || 'Ẩn danh';
    const timeStr    = formatTime(msg.createdAt || new Date());

    // ── Date divider (insert when date changes) ──────────────────────────────
    const msgDate    = new Date(msg.createdAt || Date.now()).toDateString();
    const lastDivider = wrap.querySelector('.date-divider:last-of-type');
    const lastDate   = lastDivider?.dataset.date;
    if (msgDate !== lastDate) {
        const divider = document.createElement('div');
        divider.className   = 'date-divider';
        divider.dataset.date = msgDate;
        divider.innerHTML   = `<span>${formatDateLabel(msg.createdAt)}</span>`;
        wrap.appendChild(divider);
    }
    // ─────────────────────────────────────────────────────────────────────────

    const row = document.createElement('div');
    row.className = `msg-row ${isMe ? 'me' : 'other'}`;

    if (isMe) {
        row.innerHTML = `
            <div class="msg-content">
                <div class="bubble">${esc(msg.content)}</div>
                <span class="msg-time">${timeStr}</span>
            </div>`;
    } else {
        row.innerHTML = `
            <div class="msg-avatar">${initials(senderName)}</div>
            <div class="msg-content">
                <span class="msg-sender">${esc(senderName)}</span>
                <div class="bubble">${esc(msg.content)}</div>
                <span class="msg-time">${timeStr}</span>
            </div>`;
    }

    wrap.appendChild(row);
    // Auto-scroll to bottom
    wrap.scrollTop = wrap.scrollHeight;
}

// ── FOUND USER CARD ────────────────────────────────────────────────────────────

/**
 * Show the found-user card with user details.
 * @param {{ fullName: string, username: string }} user
 */
export function showFoundUserCard(user) {
    document.getElementById('foundName').textContent     = user.fullName;
    document.getElementById('foundUsername').textContent = `@${user.username}`;
    document.getElementById('foundUserCard').style.display = 'block';
}

/** Hide the found-user card. */
export function hideFoundUserCard() {
    document.getElementById('foundUserCard').style.display = 'none';
    document.getElementById('phoneInput').value = '';
}

// ── TABS ───────────────────────────────────────────────────────────────────────

/**
 * Switch the sidebar tab.
 * @param {'group'|'private'} type
 */
export function switchTab(type) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === type);
    });
    document.querySelectorAll('.panel').forEach(panel => {
        panel.classList.toggle('active', panel.id === `panel-${type}`);
    });
}

// ── INPUT ──────────────────────────────────────────────────────────────────────

/** Focus the message input. */
export function focusInput() {
    document.getElementById('msgInput')?.focus();
}

/** Clear and return the current message input value. */
export function consumeInput() {
    const input = document.getElementById('msgInput');
    const val   = input.value.trim();
    input.value = '';
    return val;
}