<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ChatApp – ${fullName}</title>
    <link rel="stylesheet" href="/css/chat.css">
</head>
<body>

<!-- ── SIDEBAR ────────────────────────────────────────────────────────────────── -->
<div class="sidebar">

    <div class="sidebar-header">
        <div class="user-info">
            <div class="avatar" id="myAvatar"></div>
            <div>
                <div class="name">${fullName}</div>
                <div class="uname">@${username}</div>
            </div>
        </div>

        <div class="sidebar-tabs">
            <button class="tab-btn active" data-tab="group"
                    onclick="App.switchTab('group')">Nhóm</button>
            <button class="tab-btn"        data-tab="private"
                    onclick="App.switchTab('private')">Chat riêng</button>
        </div>
    </div>

    <div class="sidebar-body">

        <!-- ── GROUP PANEL ────────────────────────────────────────────────── -->
        <div class="panel active" id="panel-group">
            <div class="section-label">Tham gia phòng</div>
            <div class="join-box">
                <input type="text" id="roomCodeInput" placeholder="Nhập mã phòng..."
                       onkeydown="if(event.key==='Enter') App.joinRoom()">
                <button onclick="App.joinRoom()">Vào</button>
            </div>

            <div class="section-label">Phòng của bạn</div>
            <div id="groupRoomList"></div>
        </div>

        <!-- ── PRIVATE PANEL ──────────────────────────────────────────────── -->
        <div class="panel" id="panel-private">
            <div class="section-label">Tìm người dùng</div>
            <div class="find-box">
                <input type="text" id="phoneInput" placeholder="Số điện thoại..."
                       onkeydown="if(event.key==='Enter') App.findUser()">
                <button onclick="App.findUser()">Tìm</button>
            </div>

            <div class="found-user-card" id="foundUserCard">
                <div class="fuc-name" id="foundName"></div>
                <div class="fuc-user" id="foundUsername"></div>
                <button onclick="App.startPrivateChat()">Bắt đầu trò chuyện</button>
            </div>

            <div class="section-label">Trò chuyện</div>
            <div id="privateRoomList"></div>
        </div>

    </div>
</div>

<!-- ── MAIN CHAT AREA ──────────────────────────────────────────────────────────── -->
<div class="chat-main">

    <!-- Header (hidden until a room is opened) -->
    <div class="chat-header" id="chatHeader" style="display:none;">
        <div class="ch-avatar" id="chatAvatar"></div>
        <div>
            <div class="ch-name" id="chatTitle">—</div>
            <div class="ch-sub"  id="chatSub"></div>
        </div>
    </div>

    <!-- Empty / welcome state -->
    <div class="empty-state" id="emptyState">
        <div class="es-icon">💬</div>
        <h3>Chào mừng, ${fullName}!</h3>
        <p>Tham gia một phòng nhóm hoặc tìm người để bắt đầu trò chuyện.</p>
    </div>

    <!-- Messages scroll area -->
    <div class="messages-wrap" id="messagesWrap" style="display:none;"></div>

    <!-- Input bar -->
    <div class="input-area" id="inputArea" style="display:none;">
        <input type="text" id="msgInput" placeholder="Nhập tin nhắn..."
               onkeydown="if(event.key==='Enter') App.sendMessage()">
        <button class="send-btn" onclick="App.sendMessage()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="22" y1="2" x2="11" y2="13"></line>
                <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
            </svg>
        </button>
    </div>
</div>

<!-- Toast notification container -->
<div class="toast" id="toast"></div>

<!-- ── STOMP / SockJS libs (CDN, no ES module) ───────────────────────────────── -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<!--
    Bootstrap the ES module app.
    We expose `App` on window so inline onclick handlers (which live outside
    module scope) can call the controller functions directly.
-->
<script type="module">
    import { init, joinRoom, findUser, startPrivateChat, sendMessage, switchTab }
        from '/js/chat.js';

    // Expose to global scope for inline HTML event handlers
    window.App = { init, joinRoom, findUser, startPrivateChat, sendMessage, switchTab };

    // Kick off – username & fullName are injected by the JSP
    App.init('${username}', '${fullName}');
</script>

</body>
</html>
