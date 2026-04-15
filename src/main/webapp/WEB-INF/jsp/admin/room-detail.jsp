<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<span id="meta-room-name" class="d-none"><c:out value="${room.name}"/></span>

<!-- ══ BACK + HEADING ══ -->
<div style="margin-bottom:28px">
  <a href="${ctx}/admin/rooms" style="
        display:inline-flex; align-items:center; gap:7px;
        color:var(--text-muted); text-decoration:none;
        font-size:13px; font-weight:500;
        margin-bottom:16px;
        transition: color .2s;
    " onmouseover="this.style.color='var(--text-primary)'" onmouseout="this.style.color='var(--text-muted)'">
    <i class="bi bi-arrow-left"></i> Quay lại danh sách
  </a>

  <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px">
    <div style="display:flex; align-items:center; gap:16px">
      <div style="
                width:52px; height:52px;
                background: linear-gradient(135deg, rgba(108,99,255,.4), rgba(0,212,170,.3));
                border-radius:14px;
                display:flex; align-items:center; justify-content:center;
                font-family:'Syne',sans-serif;
                font-size:1.4rem; font-weight:800;
            ">${room.name.substring(0,1).toUpperCase()}</div>
      <div>
        <h1 class="page-heading" style="margin-bottom:4px">${room.name}</h1>
        <div style="display:flex; align-items:center; gap:10px; color:var(--text-muted); font-size:13px">
          <c:choose>
            <c:when test="${room.type == 'GROUP'}">
              <span class="badge-type badge-group"><i class="bi bi-people-fill"></i> GROUP</span>
            </c:when>
            <c:otherwise>
              <span class="badge-type badge-private"><i class="bi bi-lock-fill"></i> PRIVATE</span>
            </c:otherwise>
          </c:choose>
          <span><i class="bi bi-hash"></i> ${room.id}</span>
          <span><i class="bi bi-people me-1"></i>${memberCount} thành viên</span>
        </div>
      </div>
    </div>

    <div style="display:flex; gap:10px; flex-wrap:wrap">
      <button class="btn-accent"
              style="background:rgba(0,212,170,.15);color:var(--accent2);box-shadow:none;border:1px solid rgba(0,212,170,.25)"
              onclick="generateInviteCode()">
        <i class="bi bi-key"></i> Tạo mã mời
      </button>
      <button class="btn-accent" onclick="openAddMemberModal()">
        <i class="bi bi-person-plus"></i> Thêm thành viên
      </button>
    </div>
  </div>
</div>

<!-- ══ DETAIL INFO CARD ══ -->
<div class="admin-card mb-4">
  <div class="admin-card-header">
        <span class="admin-card-title">
            <i class="bi bi-info-circle me-2" style="color:var(--accent)"></i>Thông tin phòng
        </span>
  </div>
  <div style="padding:24px">
    <div class="detail-grid">
      <div class="detail-item">
        <div class="detail-item-label">ID phòng</div>
        <div class="detail-item-value" style="font-family:monospace; color:var(--accent)">#${room.id}</div>
      </div>
      <div class="detail-item">
        <div class="detail-item-label">Tên phòng</div>
        <div class="detail-item-value">${room.name}</div>
      </div>
      <div class="detail-item">
        <div class="detail-item-label">Loại</div>
        <div class="detail-item-value">${room.type}</div>
      </div>
      <div class="detail-item">
        <div class="detail-item-label">Người tạo (ID)</div>
        <div class="detail-item-value">${room.createdBy}</div>
      </div>
      <div class="detail-item">
        <div class="detail-item-label">Ngày tạo</div>
        <div class="detail-item-value" style="color:var(--text-muted); font-size:13px">
          <span style="color:var(--text-muted); font-size:12.5px">
            ${room.createdAtFormatted}
          </span>
        </div>
      </div>
      <div class="detail-item">
        <div class="detail-item-label">Mã mời hiện tại</div>
        <div class="detail-item-value">
          <c:choose>
            <c:when test="${not empty room.inviteCode}">
              <span id="invite-code-display" class="invite-code-box">${room.inviteCode}</span>
            </c:when>
            <c:otherwise>
              <span id="invite-code-display" style="color:var(--text-muted); font-style:italic">Chưa tạo mã mời</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ══ MEMBERS TABLE ══ -->
<div class="admin-card">
  <div class="admin-card-header">
        <span class="admin-card-title">
            <i class="bi bi-people me-2" style="color:var(--accent)"></i>
            Danh sách thành viên
        </span>
    <span id="member-count-badge" style="
            background:rgba(108,99,255,.15); color:var(--accent);
            padding:4px 12px; border-radius:20px;
            font-size:12px; font-weight:600;
        ">${memberCount} người</span>
  </div>
  <div class="admin-card-body">
    <table id="memberTable" class="table-dark-custom" style="width:100%">
      <thead>
      <tr>
        <th>User ID</th>
        <th>Username</th>
        <th>Họ và tên</th>
        <th>Số điện thoại</th>
        <th style="text-align:center">Thao tác</th>
      </tr>
      </thead>
      <tbody id="member-tbody">
      <c:forEach var="member" items="${members}">
        <tr id="member-row-${member.userId}">
          <td>
            <span style="color:var(--text-muted); font-size:12px; font-family:monospace">#${member.userId}</span>
          </td>
          <td>
            <div style="display:flex; align-items:center; gap:9px">
                                <span style="
                                    width:30px; height:30px;
                                    border-radius:8px;
                                    background:rgba(108,99,255,.2);
                                    display:flex; align-items:center; justify-content:center;
                                    font-size:11px; font-weight:700; color:var(--accent);
                                    flex-shrink:0;
                                ">
                                    <c:choose>
                                      <c:when test="${not empty member.username}">${member.username.substring(0,1).toUpperCase()}</c:when>
                                      <c:otherwise>?</c:otherwise>
                                    </c:choose>
                                </span>
              <span style="font-weight:500">
                                    <c:out value="${member.username}" default="—"/>
                                </span>
            </div>
          </td>
          <td>
            <c:out value="${member.fullName}" default="—"/>
          </td>
          <td>
                            <span style="color:var(--text-muted); font-size:12.5px">
                                <i class="bi bi-telephone me-1"></i>
                                <c:out value="${member.phone}" default="—"/>
                            </span>
          </td>
          <td>
            <div style="display:flex; justify-content:center">
              <button class="btn-icon danger"
                      title="Xóa thành viên"
                      onclick="removeMember(${member.userId}, '${member.username}')">
                <i class="bi bi-person-dash"></i>
              </button>
            </div>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>


<!-- ══════════════════════════════════════ -->
<!--       MODAL: THÊM THÀNH VIÊN          -->
<!-- ══════════════════════════════════════ -->
<div class="modal fade" id="addMemberModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="bi bi-person-plus me-2" style="color:var(--accent2)"></i>Thêm thành viên
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p style="color:var(--text-muted); font-size:13px; margin-bottom:20px">
          Nhập số điện thoại của người dùng cần thêm vào phòng <strong style="color:var(--text-primary)">${room.name}</strong>.
        </p>
        <div>
          <label class="form-label">Số điện thoại</label>
          <div style="display:flex; gap:10px">
            <input type="tel" class="form-control" id="input-phone"
                   placeholder="Ví dụ: 0912345678"
                   style="flex:1">
            <button class="btn-accent"
                    style="white-space:nowrap; padding:9px 16px"
                    onclick="submitAddMember()">
              <i class="bi bi-check-lg"></i> Thêm
            </button>
          </div>
        </div>
        <div id="add-member-result" style="margin-top:16px; display:none">
          <div style="
                        background:rgba(0,212,170,.08);
                        border:1px solid rgba(0,212,170,.2);
                        border-radius:10px;
                        padding:12px 16px;
                        color:var(--accent2); font-size:13.5px;
                    " id="add-member-success-msg"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button"
                data-bs-dismiss="modal"
                style="background:var(--bg-surface);color:var(--text-muted);border:1px solid var(--border);border-radius:9px;padding:9px 18px;cursor:pointer">
          Đóng
        </button>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════ -->
<!--      MODAL: XÁC NHẬN XÓA THÀNH VIÊN  -->
<!-- ══════════════════════════════════════ -->
<div class="modal fade" id="removeMemberModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered modal-sm">
    <div class="modal-content">
      <div class="modal-header" style="border-color:rgba(255,79,109,.2)!important">
        <h5 class="modal-title" style="color:var(--danger)">
          <i class="bi bi-person-dash me-2"></i>Xóa thành viên
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" style="text-align:center; padding:28px 24px!important">
        <div style="
                    width:56px; height:56px;
                    background:rgba(255,79,109,.1);
                    border-radius:50%;
                    display:flex; align-items:center; justify-content:center;
                    margin:0 auto 14px;
                    font-size:1.4rem; color:var(--danger);
                "><i class="bi bi-person-x"></i></div>
        <p style="font-weight:600; margin-bottom:6px">Xóa thành viên này?</p>
        <p id="remove-member-name" style="color:var(--text-muted); font-size:13px"></p>
      </div>
      <div class="modal-footer" style="justify-content:center">
        <button data-bs-dismiss="modal"
                style="background:var(--bg-surface);color:var(--text-muted);border:1px solid var(--border);border-radius:9px;padding:9px 18px;cursor:pointer">
          Không
        </button>
        <button id="btn-confirm-remove"
                style="background:var(--danger);color:#fff;border:none;border-radius:9px;padding:9px 20px;font-weight:600;cursor:pointer">
          <i class="bi bi-person-dash me-1"></i> Xóa
        </button>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════ -->
<!--              JAVASCRIPT               -->
<!-- ══════════════════════════════════════ -->
<script>
  const ROOM_ID = ${room.id};

  $(document).ready(function () {
    $('#memberTable').DataTable({
      language: {
        search:         "Tìm kiếm:",
        lengthMenu:     "Hiển thị _MENU_ dòng",
        info:           "Trang _PAGE_ / _PAGES_ &mdash; _TOTAL_ thành viên",
        paginate:       { previous: "‹", next: "›" },
        zeroRecords:    "Không tìm thấy thành viên",
        emptyTable:     "Chưa có thành viên nào"
      },
      pageLength: 10,
      order: [[0, 'asc']],
      columnDefs: [{ orderable: false, targets: 4 }]
    });
  });

  // ── Add member modal ──
  let addModal;
  function openAddMemberModal() {
    if (!addModal) addModal = new bootstrap.Modal(document.getElementById('addMemberModal'));
    document.getElementById('input-phone').value = '';
    document.getElementById('add-member-result').style.display = 'none';
    addModal.show();
  }

  // ── Submit add member (Fetch API) ──
  function submitAddMember() {
    const phone = document.getElementById('input-phone').value.trim();
    if (!phone) { showToast('Vui lòng nhập số điện thoại', 'error'); return; }

    fetch((window.__CTX || '') + '/api/admin/rooms/' + ROOM_ID + '/members', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone })
    })
            .then(res => {
              if (!res.ok) return res.text().then(t => { throw new Error(t || 'Lỗi thêm thành viên'); });
              return res.json();
            })
            .then(member => {
              // Update count badge
              const tbody = document.getElementById('member-tbody');
              const count = tbody.querySelectorAll('tr').length + 1;
              document.getElementById('member-count-badge').textContent = count + ' người';

              // Show success in modal
              const resultDiv = document.getElementById('add-member-result');
              document.getElementById('add-member-success-msg').textContent =
                      '✓ Đã thêm ' + (member.fullName || member.username) + ' (' + member.phone + ') vào phòng!';
              resultDiv.style.display = 'block';

              showToast('Thêm thành viên thành công!', 'success');

              // Reload to update DataTable
              setTimeout(() => location.reload(), 1200);
            })
            .catch(err => showToast(err.message, 'error'));
  }

  // ── Remove member ──
  let pendingUserId = null;
  let removeModal;

  function removeMember(userId, username) {
    pendingUserId = userId;
    document.getElementById('remove-member-name').textContent =
            (username || 'User') + ' (ID: ' + userId + ')';
    if (!removeModal) removeModal = new bootstrap.Modal(document.getElementById('removeMemberModal'));
    removeModal.show();
  }

  document.getElementById('btn-confirm-remove').addEventListener('click', function () {
    if (!pendingUserId) return;
    fetch((window.__CTX || '') + '/api/admin/rooms/' + ROOM_ID + '/members/' + pendingUserId, { method: 'DELETE' })
            .then(res => {
              if (res.status === 204 || res.ok) {
                const row = document.getElementById('member-row-' + pendingUserId);
                if (row) row.remove();
                if (removeModal) removeModal.hide();
                showToast('Đã xóa thành viên khỏi phòng', 'success');

                // Update count
                const tbody = document.getElementById('member-tbody');
                const count = tbody.querySelectorAll('tr').length;
                document.getElementById('member-count-badge').textContent = count + ' người';

                pendingUserId = null;
              } else {
                throw new Error('Xóa thất bại');
              }
            })
            .catch(err => showToast(err.message, 'error'));
  });

  // ── Generate invite code (Fetch API) ──
  function generateInviteCode() {
    const roomName = document.getElementById('meta-room-name').textContent;
    if (!confirm('Tạo mã mời mới cho phòng "' + roomName + '"?')) return;

    fetch((window.__CTX || '') + '/api/admin/rooms/' + ROOM_ID + '/invite-code', { method: 'POST' })
            .then(res => {
              if (!res.ok) throw new Error('Lỗi tạo mã mời');
              return res.json();
            })
            .then(data => {
              const el = document.getElementById('invite-code-display');
              el.className = 'invite-code-box';
              el.textContent = data.inviteCode;
              el.style.animation = 'none';
              void el.offsetWidth; // force reflow
              el.style.animation = 'fadeIn .4s ease';
              showToast('Mã mời mới: ' + data.inviteCode, 'success');
            })
            .catch(err => showToast(err.message, 'error'));
  }
</script>
