/**
 * websocket.js – STOMP over SockJS connection manager
 *
 * Responsibilities:
 *  - Establish & reconnect the STOMP connection
 *  - Subscribe / unsubscribe to room topics
 *  - Send chat messages
 *  - Expose callbacks for incoming messages
 */

import { toast } from './toast.js';

let stompClient = null;
const subscriptions = {}; // roomId → STOMP subscription handle
let _onRoomMessage = null;   // (msg) → void
let _onPrivateMessage = null; // (msg) → void
let _onConnected = null;     // () → void

/**
 * Initialise and connect.
 * @param {Object} callbacks
 * @param {Function} callbacks.onRoomMessage    - Called when a subscribed room gets a message
 * @param {Function} callbacks.onPrivateMessage - Called on /user/queue/messages
 * @param {Function} callbacks.onConnected      - Called once connection is established
 */
export function connect({ onRoomMessage, onPrivateMessage, onConnected } = {}) {
    _onRoomMessage    = onRoomMessage    || (() => {});
    _onPrivateMessage = onPrivateMessage || (() => {});
    _onConnected      = onConnected      || (() => {});

    _connect();
}

function _connect() {
    const socket = new SockJS('/ws');
    stompClient = Stomp.over(socket);
    stompClient.debug = null; // Suppress STOMP debug logs in console

    stompClient.connect(
        {},
        _onStompConnected,
        _onStompError
    );
}

function _onStompConnected() {
    // Subscribe to personal queue for private/system messages
    stompClient.subscribe('/user/queue/messages', (frame) => {
        try {
            const msg = JSON.parse(frame.body);
            _onPrivateMessage(msg);
        } catch (e) {
            console.error('[WS] Failed to parse private message', e);
        }
    });

    _onConnected();
}

function _onStompError(err) {
    console.error('[WS] STOMP error:', err);
    toast('Mất kết nối. Đang thử lại...', 3000, 'error');
    // Reconnect after 3 s
    setTimeout(_connect, 3000);
}

/**
 * Subscribe to a room topic (idempotent – safe to call multiple times).
 * @param {number|string} roomId
 */
export function subscribeRoom(roomId) {
    if (!stompClient || !stompClient.connected) return;
    if (subscriptions[roomId]) return; // already subscribed

    subscriptions[roomId] = stompClient.subscribe(
        `/topic/room/${roomId}`,
        (frame) => {
            try {
                const msg = JSON.parse(frame.body);
                _onRoomMessage(msg);
            } catch (e) {
                console.error('[WS] Failed to parse room message', e);
            }
        }
    );
}

/**
 * Unsubscribe from a room topic.
 * @param {number|string} roomId
 */
export function unsubscribeRoom(roomId) {
    if (subscriptions[roomId]) {
        subscriptions[roomId].unsubscribe();
        delete subscriptions[roomId];
    }
}

/**
 * Send a chat message to the server via STOMP.
 * @param {Object} payload  - { content, roomId, senderUsername }
 * @returns {boolean}       - false if not connected
 */
export function sendMessage(payload) {
    if (!stompClient || !stompClient.connected) {
        toast('Chưa kết nối. Vui lòng thử lại.', 2500, 'error');
        return false;
    }

    stompClient.send('/app/chat.group', {}, JSON.stringify(payload));
    return true;
}

/**
 * Check whether STOMP is currently connected.
 * @returns {boolean}
 */
export function isConnected() {
    return !!(stompClient && stompClient.connected);
}