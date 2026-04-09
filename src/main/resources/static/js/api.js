/**
 * api.js – Thin wrapper around the ChatApp REST API
 *
 * All methods return a Promise that resolves to the parsed JSON body.
 * HTTP errors (4xx / 5xx) are rejected with an Error whose message is
 * taken from the response body when possible.
 */

/** @param {Response} res */
async function _handleResponse(res) {
    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
        const msg = data?.message || `HTTP ${res.status}`;
        throw new Error(msg);
    }
    return data;
}

/**
 * Join a GROUP room by its room code / name.
 * POST /api/chat/join-room
 * Body: { roomCode: string }
 * Response: { message, roomId?, roomName? }
 *
 * @param {string} roomCode
 * @returns {Promise<{message: string, roomId?: number, roomName?: string}>}
 */
export async function joinRoom(roomCode) {
    const res = await fetch('/api/chat/join-room', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ roomCode }),
    });
    return _handleResponse(res);
}

/**
 * Find a user by their phone number.
 * GET /api/chat/find-user?phone=...
 * Response: { id, username, fullName } | { message }
 *
 * @param {string} phone
 * @returns {Promise<{id: number, username: string, fullName: string}>}
 */
export async function findUserByPhone(phone) {
    const res = await fetch(`/api/chat/find-user?phone=${encodeURIComponent(phone)}`);
    return _handleResponse(res);
}

/**
 * Create (or retrieve existing) a PRIVATE room with another user.
 * POST /api/chat/create-private
 * Body: { targetUserId: number }
 * Response: { message, roomId, targetName }
 *
 * @param {number} targetUserId
 * @returns {Promise<{message: string, roomId: number, targetName: string}>}
 */
export async function createPrivateRoom(targetUserId) {
    const res = await fetch('/api/chat/create-private', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ targetUserId }),
    });
    return _handleResponse(res);
}

/**
 * Fetch message history for a room.
 * GET /api/chat/history/:roomId
 * Response: MessageResponse[]
 *
 * @param {number} roomId
 * @returns {Promise<Array>}
 */
export async function getRoomHistory(roomId) {
    const res = await fetch(`/api/chat/history/${roomId}`);
    return _handleResponse(res);
}

/**
 * Get all rooms the current user is a member of.
 * GET /api/chat/my-rooms
 * Response: Array<{ id, name, type }>
 *
 * @returns {Promise<Array<{id: number, name: string, type: string}>>}
 */
export async function getMyRooms() {
    const res = await fetch('/api/chat/my-rooms');
    return _handleResponse(res);
}