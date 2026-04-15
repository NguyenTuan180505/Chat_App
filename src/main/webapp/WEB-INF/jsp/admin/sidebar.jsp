<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav id="sidebar">
  <div class="sidebar-logo">
    <a href="${ctx}/admin/rooms" class="brand">
      <div class="brand-icon">
        <i class="bi bi-chat-dots-fill" style="color:#fff"></i>
      </div>
      ChatApp
    </a>
  </div>

  <div class="sidebar-nav">
    <div class="nav-section-label">Quản trị</div>

    <a href="${ctx}/admin/rooms" class="nav-item-link ${activePage == 'rooms' ? 'active' : ''}">
      <span class="nav-icon"><i class="bi bi-grid-1x2"></i></span>
      Quản lý Phòng
    </a>

    <a href="${ctx}/admin/rooms?type=GROUP" class="nav-item-link ${filterType == 'GROUP' ? 'active' : ''}">
      <span class="nav-icon"><i class="bi bi-people"></i></span>
      Nhóm (GROUP)
    </a>

    <a href="${ctx}/admin/rooms?type=PRIVATE" class="nav-item-link ${filterType == 'PRIVATE' ? 'active' : ''}">
      <span class="nav-icon"><i class="bi bi-person-lock"></i></span>
      Riêng tư (PRIVATE)
    </a>

    <div class="nav-section-label" style="margin-top:8px">Hệ thống</div>

    <a href="#" class="nav-item-link">
      <span class="nav-icon"><i class="bi bi-people-fill"></i></span>
      Người dùng
    </a>

    <a href="#" class="nav-item-link">
      <span class="nav-icon"><i class="bi bi-shield-lock"></i></span>
      Phân quyền
    </a>

    <a href="#" class="nav-item-link">
      <span class="nav-icon"><i class="bi bi-gear"></i></span>
      Cài đặt
    </a>
  </div>

  <div class="sidebar-footer">
    <div>ChatApp Admin v1.0</div>
    <div style="margin-top:3px">© 2025 com.tuan.chatapp</div>
  </div>
</nav>
