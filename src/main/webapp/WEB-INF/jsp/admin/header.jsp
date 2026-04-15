<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header id="top-header">
  <div class="header-breadcrumb">
    <i class="bi bi-house" style="font-size:13px"></i>
    <span>/</span>
    <a href="${ctx}/admin/rooms" style="color:inherit;text-decoration:none">Admin</a>
    <span>/</span>
    <span class="current">${pageTitle}</span>
  </div>

  <div class="header-actions">
    <button class="btn-icon" title="Thông báo" style="position:relative">
      <i class="bi bi-bell"></i>
      <span style="
                position:absolute; top:4px; right:4px;
                width:7px; height:7px;
                background: var(--danger);
                border-radius:50%;
                border: 1.5px solid var(--bg-card);
            "></span>
    </button>

    <button class="btn-icon" title="Làm mới" onclick="location.reload()">
      <i class="bi bi-arrow-clockwise"></i>
    </button>

    <div class="dropdown">
      <div class="header-avatar" data-bs-toggle="dropdown" style="cursor:pointer">A</div>
      <ul class="dropdown-menu dropdown-menu-end" style="
                background:var(--bg-card);
                border:1px solid var(--border);
                border-radius:10px;
                min-width:180px;
            ">
        <li>
          <a class="dropdown-item" href="#" style="color:var(--text-primary); padding:10px 16px; font-size:13.5px">
            <i class="bi bi-person me-2" style="color:var(--text-muted)"></i>Hồ sơ
          </a>
        </li>
        <li><hr class="dropdown-divider" style="border-color:var(--border)"></li>
        <li>
          <a class="dropdown-item" href="#" style="color:var(--danger); padding:10px 16px; font-size:13.5px">
            <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
          </a>
        </li>
      </ul>
    </div>
  </div>
</header>
