<script>
    const ME = "${username}";
    const ME_FULL = "${fullName}";

    // Avatar initials
    document.getElementById('myAvatar').textContent = initials(ME_FULL);

    let stompClient = null;
    let currentRoomId = null;
    let currentRoomName = '';
    let currentRoomType = '';
    let foundUserId = null;
    let subscriptions = {};

    // ── WEBSOCKET ─────────────────────────────────────────────────────────────

    function connect() {
        const socket = new SockJS('/ws');
        stompClient = Stomp.over(socket);
        stompClient.debug = null;
        stompClient.connect({}, () => {
            // Subscribe private queue
            stompClient.subscribe('/user/queue/messages', onPrivateMessage);
            loadMyRooms();
        }, err => {
            toast('Mất kết nối. Đang thử lại...', 3000);
            setTimeout(connect, 3000);
        });
    }

    // ── TABS ──────────────────────────────────────────────────────────────────

    function switchTab(type, el) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        el.classList.add('active');
        document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
        document.getElementById('panel-' + type).classList.add('active');
    }

    // ── LOAD MY ROOMS ─────────────────────────────────────────────────────────

    function loadMyRooms() {
        fetch('/api/chat/my-rooms')
            .then(r => r.json())
            .then(rooms => {
                const gList = document.getElementById('groupRoomList');
                const pList = document.getElementById('privateRoomList');
                gList.innerHTML = '';
                pList.innerHTML = '';
                rooms.forEach(r => {
                    const el = buildRoomItem(r);
                    if (r.type === 'GROUP') gList.appendChild(el);
                    else pList.appendChild(el);
                    // Auto-subscribe
                    subscribeRoom(r.id);
                });
            });
    }

    function buildRoomItem(room) {
        const div = document.createElement('div');
        div.className = 'room-item';
        div.id = 'ri-' + room.id;
        const displayName = room.type === 'PRIVATE'
            ? (room.name.replace('PRIVATE_', '').replace(/_\d+/, '') || room.name)
            : room.name;
        div.innerHTML = `
            <div class="room-icon ${room.type === 'PRIVATE' ? 'private' : 'group'}">
                ${room.type === 'PRIVATE' ? '👤' : '#'}
            </div>
            <div class="room-info">
                <div class="rname">${esc(room.name)}</div>
                <div class="rtype">${room.type === 'PRIVATE' ? 'Riêng tư' : 'Nhóm'}</div>
            </div>`;
        div.onclick = () => openRoom(room);
        return div;
    }

    function subscribeRoom(roomId) {
        if (!stompClient || subscriptions[roomId]) return;
        subscriptions[roomId] = stompClient.subscribe(
            '/topic/room/' + roomId,
            payload => {
                const msg = JSON.parse(payload.body);
                if (msg.roomId == currentRoomId) appendMessage(msg);
            }
        );
    }

    // ── OPEN ROOM ─────────────────────────────────────────────────────────────

    function openRoom(room) {
        currentRoomId = room.id;
        currentRoomName = room.name;
        currentRoomType = room.type;

        document.querySelectorAll('.room-item').forEach(el => el.classList.remove('active'));
        const ri = document.getElementById('ri-' + room.id);
        if (ri) ri.classList.add('active');

        document.getElementById('emptyState').style.display = 'none';
        document.getElementById('chatHeader').style.display = 'flex';
        document.getElementById('messagesWrap').style.display = 'flex';
        document.getElementById('inputArea').style.display = 'flex';

        const av = document.getElementById('chatAvatar');
        av.textContent = room.type === 'PRIVATE' ? '👤' : '#';
        av.style.background = room.type === 'PRIVATE' ? '#dcfce7' : '#eff6ff';
        av.style.fontSize = '18px';

        document.getElementById('chatTitle').textContent = room.name;
        document.getElementById('chatSub').textContent =
            room.type === 'PRIVATE' ? 'Trò chuyện riêng tư' : 'Phòng nhóm';

        document.getElementById('messagesWrap').innerHTML = '';

        // Load history
        fetch('/api/chat/history/' + room.id)
            .then(r => r.json())
            .then(msgs => {
                if (msgs.length === 0) {
                    const wrap = document.getElementById('messagesWrap');
                    wrap.innerHTML = `
                        <div style="text-align:center;margin:auto;">
                            <div style="font-size:40px;margin-bottom:8px;">🗨️</div>
                            <p style="font-size:14px;color:var(--text2);">Chưa có tin nhắn nào. Hãy bắt đầu trò chuyện!</p>
                        </div>`;
                    return;
                }
                msgs.forEach(m => appendMessage(m));
            });

        subscribeRoom(room.id);
        document.getElementById('msgInput').focus();
    }

    // ── JOIN GROUP ROOM ───────────────────────────────────────────────────────

    function joinRoom() {
        const code = document.getElementById('roomCodeInput').value.trim();
        if (!code) { toast('Vui lòng nhập mã phòng'); return; }

        fetch('/api/chat/join-room', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ roomCode: code })
        })
            .then(r => r.json())
            .then(data => {
                toast(data.message);
                document.getElementById('roomCodeInput').value = '';
                if (data.roomId) {
                    loadMyRooms();
                    // Open the room after short delay
                    setTimeout(() => {
                        const room = { id: data.roomId, name: data.roomName || code, type: 'GROUP' };
                        openRoom(room);
                    }, 400);
                }
            })
            .catch(() => toast('Có lỗi xảy ra'));
    }

    // ── FIND USER ────────────────────────────────────────────────────────────

    function findUser() {
        const phone = document.getElementById('phoneInput').value.trim();
        if (!phone) { toast('Nhập số điện thoại'); return; }

        fetch('/api/chat/find-user?phone=' + encodeURIComponent(phone))
            .then(r => r.json())
            .then(data => {
                if (data.message) { toast(data.message); return; }
                foundUserId = data.id;
                document.getElementById('foundName').textContent = data.fullName;
                document.getElementById('foundUsername').textContent = '@' + data.username;
                document.getElementById('foundUserCard').style.display = 'block';
            })
            .catch(() => toast('Có lỗi xảy ra'));
    }

    function startPrivateChat() {
        if (!foundUserId) return;
        fetch('/api/chat/create-private', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ targetUserId: foundUserId })
        })
            .then(r => r.json())
            .then(data => {
                toast(data.message);
                document.getElementById('foundUserCard').style.display = 'none';
                document.getElementById('phoneInput').value = '';
                foundUserId = null;
                if (data.roomId) {
                    switchTab('private', document.querySelectorAll('.tab-btn')[1]);
                    loadMyRooms();
                    setTimeout(() => {
                        const room = { id: data.roomId, name: data.targetName || 'Chat riêng', type: 'PRIVATE' };
                        openRoom(room);
                    }, 400);
                }
            })
            .catch(() => toast('Có lỗi xảy ra'));
    }

    // ── SEND MESSAGE ─────────────────────────────────────────────────────────

    function sendMessage() {
        const input = document.getElementById('msgInput');
        const content = input.value.trim();
        if (!content || !currentRoomId || !stompClient) return;

        const payload = {
            content: content,
            senderId: ME,
            roomId: currentRoomId
        };

        stompClient.send('/app/chat.group', {}, JSON.stringify(payload));

        // Optimistic UI
        appendMessage({
            senderName: ME_FULL,
            senderId: null,   // mark as "me" via senderUsername
            senderUsername: ME,
            content: content,
            createdAt: new Date().toISOString(),
            _isMe: true
        });

        input.value = '';
        input.focus();
    }

    function onPrivateMessage(payload) {
        const msg = JSON.parse(payload.body);
        if (msg.roomId == currentRoomId) appendMessage(msg);
    }

    // ── RENDER MESSAGE ────────────────────────────────────────────────────────

    function appendMessage(msg) {
        const wrap = document.getElementById('messagesWrap');

        // Clear empty placeholder
        const placeholder = wrap.querySelector('div[style*="text-align:center"]');
        if (placeholder) placeholder.remove();

        const isMe = msg._isMe || (msg.senderUsername === ME) ||
            (msg.senderId && String(msg.senderId) === ME);

        const senderName = msg.senderName || msg.username || 'Ẩn danh';
        const timeStr = formatTime(msg.createdAt || new Date());

        const row = document.createElement('div');
        row.className = 'msg-row ' + (isMe ? 'me' : 'other');

        if (!isMe) {
            row.innerHTML = `
                <div class="msg-avatar">${initials(senderName)}</div>
                <div class="msg-content">
                    <span class="msg-sender">${esc(senderName)}</span>
                    <div class="bubble">${esc(msg.content)}</div>
                    <span class="msg-time">${timeStr}</span>
                </div>`;
        } else {
            row.innerHTML = `
                <div class="msg-content">
                    <div class="bubble">${esc(msg.content)}</div>
                    <span class="msg-time">${timeStr}</span>
                </div>`;
        }

        wrap.appendChild(row);
        wrap.scrollTop = wrap.scrollHeight;
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────

    function initials(name) {
        if (!name) return '?';
        const parts = name.trim().split(' ');
        return parts.length >= 2
            ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
            : name.substring(0, 2).toUpperCase();
    }

    function esc(str) {
        if (!str) return '';
        return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    function formatTime(iso) {
        try {
            const d = new Date(iso);
            return d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
        } catch { return ''; }
    }

    function toast(msg, duration = 2500) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.classList.add('show');
        setTimeout(() => t.classList.remove('show'), duration);
    }

    // ── INIT ─────────────────────────────────────────────────────────────────
    window.onload = connect;
</script>