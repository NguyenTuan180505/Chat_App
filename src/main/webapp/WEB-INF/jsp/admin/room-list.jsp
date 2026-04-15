<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- ══ PAGE HEADING ══ -->
<div style="display:flex; align-items:flex-start; justify-content:space-between; flex-wrap:wrap; gap:16px; margin-bottom:28px">
    <div>
        <h1 class="page-heading">
            <i class="bi bi-grid-1x2" style="color:var(--accent); margin-right:10px"></i>
            Quản lý Phòng Chat
        </h1>
        <p class="page-subheading">Xem, tạo, xóa và quản lý tất cả các phòng chat.</p>
    </div>
    <button class="btn-accent" onclick="openCreateModal()">
        <i class="bi bi-plus-lg"></i> Tạo phòng mới
    </button>
</div>

<!-- ══ STAT CARDS ══ -->
<div class="row g-3 mb-4">
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-icon purple"><i class="bi bi-grid-3x3-gap"></i></div>
            <div>
                <div class="stat-value">${totalRooms}</div>
                <div class="stat-label">Tổng số phòng</div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-icon teal"><i class="bi bi-people-fill"></i></div>
            <div>
                <div class="stat-value">${totalGroup}</div>
                <div class="stat-label">Phòng nhóm (GROUP)</div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="stat-card">
            <div class="stat-icon red"><i class="bi bi-person-lock"></i></div>
            <div>
                <div class="stat-value">${totalPrivate}</div>
                <div class="stat-label">Phòng riêng tư (PRIVATE)</div>
            </div>
        </div>
    </div>
</div>

<!-- ══ FILTER PILLS ══ -->
<div class="filter-pills mb-4">
    <a href="${ctx}/admin/rooms"              class="pill ${filterType == 'ALL'     ? 'active' : ''}">Tất cả</a>
    <a href="${ctx}/admin/rooms?type=GROUP"   class="pill ${filterType == 'GROUP'   ? 'active' : ''}"><i class="bi bi-people me-1"></i>GROUP</a>
    <a href="${ctx}/admin/rooms?type=PRIVATE" class="pill ${filterType == 'PRIVATE' ? 'active' : ''}"><i class="bi bi-lock me-1"></i>PRIVATE</a>
</div>

<!-- ══ TABLE CARD ══ -->
<div class="admin-card">
    <div class="admin-card-header">
        <span class="admin-card-title">
            <i class="bi bi-table me-2" style="color:var(--accent)"></i>Danh sách phòng
        </span>
        <span style="color:var(--text-muted); font-size:12px">
            Hiển thị <strong style="color:var(--text-primary)">${rooms.size()}</strong> phòng
        </span>
    </div>
    <div class="admin-card-body" style="padding:0 0 12px">
        <table id="roomTable" class="table-dark-custom" style="width:100%">
            <thead>
            <tr>
                <th>ID</th>
                <th>Tên phòng</th>
                <th>Loại</th>
                <th>Người tạo</th>
                <th>Mã mời</th>
                <th>Ngày tạo</th>
                <th style="text-align:center">Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="room" items="${rooms}">
                <tr id="row-${room.id}">
                    <td>
                        <span style="color:var(--text-muted); font-size:12px; font-family:monospace">#${room.id}</span>
                    </td>
                    <td>
                        <a href="${ctx}/admin/rooms/${room.id}" style="
                                color:var(--text-primary);
                                text-decoration:none;
                                font-weight:600;
                                display:flex; align-items:center; gap:9px;
                            ">
                                <span style="
                                    width:34px; height:34px;
                                    border-radius:10px;
                                    background: linear-gradient(135deg, rgba(108,99,255,.3), rgba(0,212,170,.2));
                                    display:flex; align-items:center; justify-content:center;
                                    font-family:'Syne',sans-serif;
                                    font-weight:700;
                                    font-size:13px;
                                    flex-shrink:0;
                                ">${room.name.substring(0,1).toUpperCase()}</span>
                                ${room.name}
                        </a>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${room.type == 'GROUP'}">
                                <span class="badge-type badge-group"><i class="bi bi-people-fill"></i> GROUP</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-type badge-private"><i class="bi bi-lock-fill"></i> PRIVATE</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                            <span style="color:var(--text-muted); font-size:12.5px">
                                <i class="bi bi-person me-1"></i>ID: ${room.createdBy}
                            </span>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${not empty room.inviteCode}">
                                    <span style="
                                        font-family:monospace; font-size:12px;
                                        background:rgba(0,212,170,.1); color:var(--accent2);
                                        padding:3px 8px; border-radius:6px;
                                        letter-spacing:.1em;
                                    ">${room.inviteCode}</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color:var(--text-muted); font-size:12px">— chưa có —</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                            <span style="color:var(--text-muted); font-size:12.5px">
                                    ${room.createdAtFormatted}
                            </span>
                    </td>
                    <td>
                        <div style="display:flex; justify-content:center; gap:6px">
                            <a href="${ctx}/admin/rooms/${room.id}/messages/view"
                               class="btn-accent"
                               style="background:rgba(108,99,255,.1);color:var(--accent);box-shadow:none;border:1px solid rgba(108,99,255,.25); text-decoration:none; display:inline-flex; align-items:center; gap:6px;">
                                <i class="bi bi-chat-left-text"></i> Lịch sử tin nhắn
                            </a>
                            <a href="${ctx}/admin/rooms/${room.id}" class="btn-icon" title="Xem chi tiết">
                                <i class="bi bi-eye"></i>
                            </a>
                            <button class="btn-icon danger"
                                    title="Xóa phòng"
                                    onclick="deleteRoom(${room.id}, '${room.name}')">
                                <i class="bi bi-trash3"></i>
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
<!--            MODAL: TẠO PHÒNG           -->
<!-- ══════════════════════════════════════ -->
<div class="modal fade" id="createRoomModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-plus-circle me-2" style="color:var(--accent)"></i>Tạo phòng mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-4">
                    <label class="form-label">Tên phòng</label>
                    <input type="text" class="form-control" id="input-name" placeholder="Nhập tên phòng...">
                </div>
                <div class="mb-4">
                    <label class="form-label">Loại phòng</label>
                    <select class="form-select" id="input-type">
                        <option value="GROUP">GROUP — Nhóm nhiều người</option>
                        <option value="PRIVATE">PRIVATE — Riêng tư</option>
                    </select>
                </div>
                <div class="mb-2">
                    <label class="form-label">ID người tạo</label>
                    <input type="number" class="form-control" id="input-createdBy" placeholder="Nhập User ID...">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button"
                        class="btn"
                        data-bs-dismiss="modal"
                        style="background:var(--bg-surface);color:var(--text-muted);border:1px solid var(--border);border-radius:9px;padding:9px 18px">
                    Hủy
                </button>
                <button type="button" class="btn-accent" onclick="submitCreateRoom()">
                    <i class="bi bi-check-lg"></i> Tạo phòng
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════ -->
<!--          MODAL: XÁC NHẬN XÓA          -->
<!-- ══════════════════════════════════════ -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content">
            <div class="modal-header" style="border-color:rgba(255,79,109,.2)!important">
                <h5 class="modal-title" style="color:var(--danger)">
                    <i class="bi bi-exclamation-triangle me-2"></i>Xác nhận xóa
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="text-align:center; padding:28px 24px!important">
                <div style="
                    width:60px; height:60px;
                    background:rgba(255,79,109,.1);
                    border-radius:50%;
                    display:flex; align-items:center; justify-content:center;
                    margin:0 auto 16px;
                    font-size:1.6rem; color:var(--danger);
                "><i class="bi bi-trash3"></i></div>
                <p style="color:var(--text-primary); font-weight:600; margin-bottom:8px">
                    Bạn chắc chắn muốn xóa?
                </p>
                <p id="delete-room-name" style="color:var(--text-muted); font-size:13px"></p>
            </div>
            <div class="modal-footer" style="justify-content:center">
                <button type="button"
                        data-bs-dismiss="modal"
                        style="background:var(--bg-surface);color:var(--text-muted);border:1px solid var(--border);border-radius:9px;padding:9px 18px; cursor:pointer">
                    Không
                </button>
                <button type="button" id="btn-confirm-delete"
                        style="background:var(--danger);color:#fff;border:none;border-radius:9px;padding:9px 20px;font-weight:600;cursor:pointer">
                    <i class="bi bi-trash3 me-1"></i> Xóa
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ══════════════════════════════════════ -->
<!--          JAVASCRIPT                   -->
<!-- ══════════════════════════════════════ -->
<script>
    $(document).ready(function () {
        $('#roomTable').DataTable({
            language: {
                search:          "Tìm kiếm:",
                lengthMenu:      "Hiển thị _MENU_ dòng",
                info:            "Trang _PAGE_ / _PAGES_ &mdash; tổng _TOTAL_ phòng",
                paginate: { previous: "‹", next: "›" },
                zeroRecords:     "Không tìm thấy phòng nào",
                emptyTable:      "Chưa có phòng nào"
            },
            pageLength: 10,
            order: [[0, 'desc']],
            columnDefs: [{ orderable: false, targets: 6 }]
        });
        $('#roomTable tbody').on('click', 'a', function (e) {
            e.stopPropagation();
        });
    });

    // ── Open create modal ──
    let createModal;
    function openCreateModal() {
        if (!createModal) createModal = new bootstrap.Modal(document.getElementById('createRoomModal'));
        document.getElementById('input-name').value = '';
        document.getElementById('input-createdBy').value = '';
        createModal.show();
    }

    // ── Submit create room ──
    function submitCreateRoom() {
        const name      = document.getElementById('input-name').value.trim();
        const type      = document.getElementById('input-type').value;
        const createdBy = parseInt(document.getElementById('input-createdBy').value);

        if (!name) { showToast('Vui lòng nhập tên phòng', 'error'); return; }
        if (!createdBy) { showToast('Vui lòng nhập ID người tạo', 'error'); return; }

        fetch((window.__CTX || '') + '/api/admin/rooms', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, type, createdBy })
        })
            .then(res => {
                if (!res.ok) throw new Error('Lỗi khi tạo phòng');
                return res.json();
            })
            .then(data => {
                showToast('✓ Tạo phòng "' + data.name + '" thành công!', 'success');
                if (createModal) createModal.hide();
                setTimeout(() => location.reload(), 1000);
            })
            .catch(err => showToast(err.message, 'error'));
    }

    // ── Delete room ──
    let pendingDeleteId = null;
    let deleteModal;

    function deleteRoom(roomId, roomName) {
        pendingDeleteId = roomId;
        document.getElementById('delete-room-name').textContent = 'Phòng: "' + roomName + '" (ID: ' + roomId + ')';
        if (!deleteModal) deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
        deleteModal.show();
    }

    document.getElementById('btn-confirm-delete').addEventListener('click', function () {
        if (!pendingDeleteId) return;
        fetch((window.__CTX || '') + '/api/admin/rooms/' + pendingDeleteId, { method: 'DELETE' })
            .then(res => {
                if (res.status === 204 || res.ok) {
                    const row = document.getElementById('row-' + pendingDeleteId);
                    if (row) row.remove();
                    if (deleteModal) deleteModal.hide();
                    showToast('Đã xóa phòng thành công', 'success');
                    pendingDeleteId = null;
                } else {
                    throw new Error('Xóa thất bại');
                }
            })
            .catch(err => showToast(err.message, 'error'));
    });
</script>