<div class="chat-main">
  <!-- Chat Header -->
  <div class="chat-header" id="chatHeader" style="display:none;">
    <div class="ch-avatar" id="chatAvatar"></div>
    <div>
      <div class="ch-name" id="chatTitle">—</div>
      <div class="ch-sub" id="chatSub"></div>
    </div>
  </div>

  <!-- Empty State -->
  <div class="empty-state" id="emptyState">
    <div class="es-icon">💬</div>
    <h3>Chào mừng, ${fullName}!</h3>
    <p>Tham gia một phòng nhóm hoặc tìm người để bắt đầu trò chuyện.</p>
  </div>

  <!-- Messages Area -->
  <div class="messages-wrap" id="messagesWrap" style="display:none;"></div>

  <!-- Input Area -->
  <div class="input-area" id="inputArea" style="display:none;">
    <input type="text" id="msgInput" placeholder="Nhập tin nhắn..."
           onkeydown="if(event.key==='Enter') sendMessage()">
    <button class="send-btn" onclick="sendMessage()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
           stroke-linecap="round" stroke-linejoin="round">
        <line x1="22" y1="2" x2="11" y2="13"></line>
        <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
      </svg>
    </button>
  </div>
</div>