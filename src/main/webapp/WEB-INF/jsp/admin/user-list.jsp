<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- PAGE HEADING -->
<div style="display:flex; align-items:flex-start; justify-content:space-between; flex-wrap:wrap; gap:16px; margin-bottom:28px">
  <div>
    <h1 class="page-heading">
      <i class="bi bi-people-fill" style="color:var(--accent); margin-right:10px"></i>
      Quản lý Người dùng
    </h1>
    <p class="page-subheading">Xem danh sách và quản lý tất cả tài khoản người dùng trong hệ thống.</p>
  </div>
</div>

<!-- STAT CARD -->
<div class="row g-3 mb-4">
  <div class="col-md-4">
    <div class="stat-card">
      <div class="stat-icon blue"><i class="bi bi-people"></i></div>
      <div>
        <div class="stat-value">${totalUsers}</div>
        <div class="stat-label">Tổng số người dùng</div>
      </div>
    </div>
  </div>
</div>

<!-- MAIN TABLE CARD -->
<div class="admin-card">
  <div class="admin-card-header">
        <span class="admin-card-title">
            <i class="bi bi-table me-2" style="color:var(--accent)"></i>
            Danh sách người dùng
        </span>
    <span style="color:var(--text-muted); font-size:12px">
            Hiển thị <strong style="color:var(--text-primary)">${users.size()}</strong> người dùng
        </span>
  </div>

  <div class="admin-card-body" style="padding:0;">
    <table id="userTable" class="table-dark-custom" style="width:100%">
      <thead>
      <tr>
        <th style="width:80px">ID</th>
        <th>Username</th>
        <th>Họ và tên</th>
        <th>Số điện thoại</th>
        <th style="width:140px">Vai trò</th>
        <th style="width:120px; text-align:center">Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach var="user" items="${users}">
        <tr id="row-${user.id}">
          <td>
                        <span style="color:var(--text-muted); font-family:monospace; font-size:13px;">
                            #${user.id}
                        </span>
          </td>
          <td>
            <strong style="color:var(--text-primary);">${user.username}</strong>
          </td>
          <td>${user.fullName != null && user.fullName != '' ? user.fullName : '<span style="color:var(--text-muted)">—</span>'}</td>
          <td>
                        <span style="font-family:monospace; color:var(--text-primary);">
                            ${user.phone != null && user.phone != '' ? user.phone : '—'}
                        </span>
          </td>
          <td>
                        <span class="badge-type badge-role">
                            <i class="bi bi-shield-check me-1"></i>
                            ${user.roleName}
                        </span>
          </td>
          <td style="text-align:center">
            <button onclick="deleteUser(${user.id}, '${user.username}')"
                    class="btn-icon danger"
                    title="Xóa người dùng"
                    style="margin: 0 auto;">
              <i class="bi bi-trash3"></i>
            </button>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteUserModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered modal-sm">
    <div class="modal-content">
      <div class="modal-header" style="border-color:rgba(255,79,109,.2)">
        <h5 class="modal-title" style="color:var(--danger)">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>Xác nhận xóa
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" style="text-align:center; padding:32px 24px;">
        <div style="width:64px; height:64px; background:rgba(255,79,109,.1); border-radius:50%;
                            margin:0 auto 16px; display:flex; align-items:center; justify-content:center; font-size:28px; color:var(--danger);">
          <i class="bi bi-trash3"></i>
        </div>
        <p style="font-weight:600; color:var(--text-primary); margin-bottom:6px;">Bạn chắc chắn muốn xóa?</p>
        <p id="delete-user-info" style="color:var(--text-muted); font-size:14px;"></p>
      </div>
      <div class="modal-footer" style="justify-content:center; gap:12px;">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
                style="padding:10px 20px; border-radius:9px;">
          Hủy
        </button>
        <button type="button" id="btn-confirm-delete-user"
                style="background:var(--danger); color:#fff; border:none; padding:10px 24px; border-radius:9px; font-weight:600;">
          <i class="bi bi-trash3 me-1"></i> Xóa người dùng
        </button>
      </div>
    </div>
  </div>
</div>

<script>
  $(document).ready(function () {
    $('#userTable').DataTable({
      language: {
        search: "Tìm kiếm người dùng:",
        lengthMenu: "Hiển thị _MENU_ dòng",
        info: "Trang _PAGE_ / _PAGES_ — tổng _TOTAL_ người dùng",
        paginate: { previous: "‹", next: "›" },
        zeroRecords: "Không tìm thấy người dùng nào",
        emptyTable: "Chưa có người dùng nào trong hệ thống"
      },
      pageLength: 15,
      order: [[0, 'desc']],
      columnDefs: [
        { orderable: false, targets: 5 }   // không cho sắp xếp cột Thao tác
      ]
    });
  });

  // Biến toàn cục
  let pendingDeleteId = null;
  let deleteModal = null;

  function deleteUser(userId, username) {
    pendingDeleteId = userId;

    document.getElementById('delete-user-info').innerHTML =
            'Username: <strong>' + username + '</strong><br>ID: ' + userId;

    if (!deleteModal) {
      deleteModal = new bootstrap.Modal(document.getElementById('deleteUserModal'));
    }
    deleteModal.show();
  }

  // Xử lý nút xác nhận xóa
  document.getElementById('btn-confirm-delete-user').addEventListener('click', function () {
    if (!pendingDeleteId) return;

    fetch('/api/admin/users/' + pendingDeleteId, {
      method: 'DELETE'
    })
            .then(response => {
              if (response.ok) {
                // Xóa dòng trong bảng
                const row = document.getElementById('row-' + pendingDeleteId);
                if (row) row.remove();

                if (deleteModal) deleteModal.hide();
                showToast('✓ Đã xóa người dùng thành công!', 'success');
                pendingDeleteId = null;
              } else {
                throw new Error('Xóa người dùng thất bại');
              }
            })
            .catch(err => {
              showToast('Lỗi: ' + err.message, 'error');
            });
  });
</script>