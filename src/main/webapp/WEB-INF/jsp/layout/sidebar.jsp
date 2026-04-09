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
            <button class="tab-btn active" onclick="switchTab('group', this)">Nhóm</button>
            <button class="tab-btn" onclick="switchTab('private', this)">Chat riêng</button>
        </div>
    </div>

    <div class="sidebar-body">
        <!-- GROUP PANEL -->
        <div class="panel active" id="panel-group">
            <div class="section-label">Tham gia phòng</div>
            <div class="join-box">
                <input type="text" id="roomCodeInput" placeholder="Nhập mã phòng...">
                <button onclick="joinRoom()">Vào</button>
            </div>
            <div class="section-label">Phòng của bạn</div>
            <div id="groupRoomList"></div>
        </div>

        <!-- PRIVATE PANEL -->
        <div class="panel" id="panel-private">
            <div class="section-label">Tìm người dùng</div>
            <div class="find-box">
                <input type="text" id="phoneInput" placeholder="Số điện thoại...">
                <button onclick="findUser()">Tìm</button>
            </div>
            <div class="found-user-card" id="foundUserCard">
                <div class="fuc-name" id="foundName"></div>
                <div class="fuc-user" id="foundUsername"></div>
                <button onclick="startPrivateChat()">Bắt đầu trò chuyện</button>
            </div>
            <div class="section-label">Trò chuyện</div>
            <div id="privateRoomList"></div>
        </div>
    </div>
</div>