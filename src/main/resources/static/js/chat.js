/**
 * chat.js – Application controller (orchestrates api, websocket, ui)
 *
 * Wires together all modules. Owns the application state.
 */

import { toast }                              from './toast.js';
import { connect, subscribeRoom, sendMessage as wsSend, isConnected } from './websocket.js';
import * as API                               from './api.js';
import * as UI                                from './ui.js';
import { initials }                           from './utils.js';

// ── STATE ──────────────────────────────────────────────────────────────────────
const state = {
    /** @type {string} */ username:    '',
    /** @type {string} */ fullName:    '',
    /** @type {number|null} */ currentRoomId:   null,
    /** @type {Object|null} */ currentRoom:     null,
    /** @type {number|null} */ foundUserId:     null,
    /** @type {Map<number,Object>} */ rooms: new Map(), // roomId → room object
};

// ── INIT ───────────────────────────────────────────────────────────────────────

/**
 * Initialise the app. Called from the JSP page on DOMContentLoaded.
 * @param {string} username
 * @param {string} fullName
 */
export function init(username, fullName) {
    state.username = username;
    state.fullName = fullName;

    // Render own avatar initials
    document.getElementById('myAvatar').textContent = initials(fullName);

    connect({
        onConnected:      _onConnected,
        onRoomMessage:    _onRoomMessage,
        onPrivateMessage: _onPrivateMessage,
    });
}

// ── WEBSOCKET CALLBACKS ────────────────────────────────────────────────────────

async function _onConnected() {
    await _loadMyRooms();
}

/**
 * Receive a message on a subscribed room topic.
 * Only render it if the user is currently viewing that room.
 * @param {Object} msg
 */
function _onRoomMessage(msg) {
    if (msg.roomId == state.currentRoomId) {
        UI.appendMessage(msg, state.username);
    }
    // TODO: increment unread badge for other rooms
}

/**
 * Receive a personal (private) queue message.
 * The backend pushes these for 1-to-1 conversations.
 */
function _onPrivateMessage(msg) {
    if (msg.roomId == state.currentRoomId) {
        UI.appendMessage(msg, state.username);
    }
}

// ── ROOM LOADING ───────────────────────────────────────────────────────────────

async function _loadMyRooms() {
    try {
        const rooms = await API.getMyRooms();

        // Cache rooms in state
        state.rooms.clear();
        rooms.forEach(r => state.rooms.set(r.id, r));

        UI.renderRoomLists(rooms, state.username, openRoom);

        // Subscribe to every room's WebSocket topic
        rooms.forEach(r => subscribeRoom(r.id));
    } catch (err) {
        toast(`Không thể tải danh sách phòng: ${err.message}`, 3500, 'error');
    }
}

// ── OPEN ROOM ──────────────────────────────────────────────────────────────────

/**
 * Open (switch to) a room and load its message history.
 * @param {Object} room  - { id, name, type, targetName? }
 */
export async function openRoom(room) {
    state.currentRoomId = room.id;
    state.currentRoom   = room;

    UI.setActiveRoom(room.id);
    UI.showChatArea(room, state.username);
    UI.clearMessages();
    UI.focusInput();

    // Ensure we're subscribed (safe to call multiple times)
    subscribeRoom(room.id);

    try {
        const msgs = await API.getRoomHistory(room.id);
        if (msgs.length === 0) {
            UI.showNoMessages();
        } else {
            msgs.forEach(m => UI.appendMessage(m, state.username));
        }
    } catch (err) {
        toast(`Không thể tải lịch sử: ${err.message}`, 3000, 'error');
    }
}

// ── JOIN GROUP ROOM ────────────────────────────────────────────────────────────

export async function joinRoom() {
    const input = document.getElementById('roomCodeInput');
    const code  = input.value.trim();
    if (!code) { toast('Vui lòng nhập mã phòng'); return; }

    try {
        const data = await API.joinRoom(code);
        toast(data.message);
        input.value = '';

        if (data.roomId) {
            // Reload rooms then open the newly joined one
            await _loadMyRooms();

            const room = state.rooms.get(data.roomId) ||
                { id: data.roomId, name: data.roomName || code, type: 'GROUP' };
            openRoom(room);
        }
    } catch (err) {
        toast(err.message, 3000, 'error');
    }
}

// ── FIND USER ──────────────────────────────────────────────────────────────────

export async function findUser() {
    const phone = document.getElementById('phoneInput').value.trim();
    if (!phone) { toast('Nhập số điện thoại'); return; }

    try {
        const data = await API.findUserByPhone(phone);

        // data.message means an error message was returned
        if (data.message) { toast(data.message); return; }

        state.foundUserId = data.id;
        UI.showFoundUserCard(data);
    } catch (err) {
        toast(err.message, 3000, 'error');
    }
}

// ── START PRIVATE CHAT ─────────────────────────────────────────────────────────

export async function startPrivateChat() {
    if (!state.foundUserId) return;

    try {
        const data = await API.createPrivateRoom(state.foundUserId);
        toast(data.message);
        UI.hideFoundUserCard();
        state.foundUserId = null;

        if (data.roomId) {
            UI.switchTab('private');

            // Reload rooms so the new room appears in the sidebar
            await _loadMyRooms();

            // Attach targetName so the display name is correct
            const room = state.rooms.get(data.roomId) ||
                { id: data.roomId, name: `PRIVATE`, type: 'PRIVATE' };
            room.targetName = data.targetName;
            state.rooms.set(room.id, room);

            openRoom(room);
        }
    } catch (err) {
        toast(err.message, 3000, 'error');
    }
}

// ── SEND MESSAGE ───────────────────────────────────────────────────────────────

export function sendMessage() {
    const content = UI.consumeInput();
    if (!content)                  { return; }
    if (!state.currentRoomId)      { toast('Chọn một phòng trước'); return; }
    if (!isConnected())            { toast('Chưa kết nối, đang thử lại...', 2000, 'error'); return; }

    const payload = {
        content,
        roomId:         state.currentRoomId,
        // FIX: send username (not a DB ID) so the backend maps it via UserDetails
        senderUsername: state.username,
    };

    const sent = wsSend(payload);

    if (sent) {
        // Optimistic UI – show message immediately without waiting for server echo
        UI.appendMessage({
            senderUsername: state.username,
            senderName:     state.fullName,
            content,
            createdAt:      new Date().toISOString(),
            _isMe:          true,
        }, state.username);
    }

    UI.focusInput();
}

// ── TAB SWITCHING (exposed to HTML onclick) ─────────────────────────────────────

export function switchTab(type) {
    UI.switchTab(type);
}