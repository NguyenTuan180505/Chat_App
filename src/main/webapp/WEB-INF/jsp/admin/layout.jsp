<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${pageTitle} — ChatApp Admin</title>

  <!-- Google Fonts: Syne (display) + DM Sans (body) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

  <!-- DataTables -->
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css">

  <style>
    :root {
      --bg-base:      #0d0f14;
      --bg-surface:   #151822;
      --bg-card:      #1c2030;
      --bg-hover:     #222840;
      --accent:       #6c63ff;
      --accent-glow:  rgba(108,99,255,.35);
      --accent2:      #00d4aa;
      --danger:       #ff4f6d;
      --warning:      #ffb347;
      --text-primary: #e8eaf6;
      --text-muted:   #7e84a3;
      --border:       rgba(255,255,255,.07);
      --sidebar-w:    260px;
      --radius:       14px;
      --transition:   .22s cubic-bezier(.4,0,.2,1);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--bg-base);
      color: var(--text-primary);
      min-height: 100vh;
      display: flex;
      font-size: 14.5px;
    }

    /* ── Noise texture overlay ── */
    body::before {
      content: '';
      position: fixed; inset: 0; z-index: 0; pointer-events: none;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");
      opacity: .4;
    }

    /* ════════════ SIDEBAR ════════════ */
    #sidebar {
      width: var(--sidebar-w);
      min-height: 100vh;
      background: var(--bg-surface);
      border-right: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      position: fixed; top: 0; left: 0; bottom: 0;
      z-index: 1000;
      transition: transform var(--transition);
    }

    .sidebar-logo {
      padding: 28px 24px 20px;
      border-bottom: 1px solid var(--border);
    }
    .sidebar-logo .brand {
      font-family: 'Syne', sans-serif;
      font-size: 1.4rem;
      font-weight: 800;
      color: var(--text-primary);
      text-decoration: none;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .sidebar-logo .brand-icon {
      width: 36px; height: 36px;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      border-radius: 10px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1rem;
      box-shadow: 0 0 16px var(--accent-glow);
    }

    .sidebar-nav {
      padding: 16px 12px;
      flex: 1;
      overflow-y: auto;
    }
    .nav-section-label {
      font-size: 10px;
      font-weight: 600;
      letter-spacing: .12em;
      text-transform: uppercase;
      color: var(--text-muted);
      padding: 12px 12px 6px;
    }
    .nav-item-link {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 10px 14px;
      border-radius: 10px;
      color: var(--text-muted);
      text-decoration: none;
      font-weight: 500;
      transition: all var(--transition);
      margin-bottom: 3px;
    }
    .nav-item-link:hover {
      background: var(--bg-hover);
      color: var(--text-primary);
    }
    .nav-item-link.active {
      background: linear-gradient(90deg, rgba(108,99,255,.18), rgba(108,99,255,.06));
      color: var(--accent);
      border-left: 3px solid var(--accent);
    }
    .nav-item-link .nav-icon {
      width: 32px; height: 32px;
      display: flex; align-items: center; justify-content: center;
      border-radius: 8px;
      font-size: 1rem;
      background: rgba(255,255,255,.04);
      flex-shrink: 0;
    }
    .nav-item-link.active .nav-icon { background: rgba(108,99,255,.2); }

    .sidebar-footer {
      padding: 16px 20px;
      border-top: 1px solid var(--border);
      font-size: 12px;
      color: var(--text-muted);
    }

    /* ════════════ MAIN ════════════ */
    /* No z-index here: a low stacking context traps .modal/.modal-backdrop inside
       #main-wrapper so the whole layer sits below #sidebar (z-index 1000); clicks on
       the dimmed area (and sometimes the dialog) then hit the sidebar instead. */
    #main-wrapper {
      margin-left: var(--sidebar-w);
      flex: 1;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
      position: relative;
    }

    /* ════════════ HEADER ════════════ */
    #top-header {
      background: rgba(21,24,34,.85);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-bottom: 1px solid var(--border);
      padding: 14px 32px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky; top: 0; z-index: 900;
    }
    .header-breadcrumb {
      display: flex; align-items: center; gap: 8px;
      color: var(--text-muted);
      font-size: 13px;
    }
    .header-breadcrumb .current { color: var(--text-primary); font-weight: 600; }
    .header-actions { display: flex; align-items: center; gap: 12px; }
    .header-avatar {
      width: 36px; height: 36px;
      border-radius: 50%;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      display: flex; align-items: center; justify-content: center;
      font-weight: 700; font-size: 13px;
      cursor: pointer;
    }

    /* ════════════ PAGE CONTENT ════════════ */
    #page-content {
      padding: 32px;
      flex: 1;
    }
    .page-heading {
      font-family: 'Syne', sans-serif;
      font-size: 1.75rem;
      font-weight: 700;
      color: var(--text-primary);
      margin-bottom: 4px;
    }
    .page-subheading {
      color: var(--text-muted);
      font-size: 13.5px;
      margin-bottom: 28px;
    }

    /* ════════════ STAT CARDS ════════════ */
    .stat-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 22px;
      display: flex;
      align-items: center;
      gap: 16px;
      transition: transform var(--transition), box-shadow var(--transition);
    }
    .stat-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 32px rgba(0,0,0,.3);
    }
    .stat-icon {
      width: 52px; height: 52px;
      border-radius: 14px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.4rem;
      flex-shrink: 0;
    }
    .stat-icon.purple { background: rgba(108,99,255,.15); color: var(--accent); }
    .stat-icon.teal   { background: rgba(0,212,170,.12);  color: var(--accent2); }
    .stat-icon.red    { background: rgba(255,79,109,.12); color: var(--danger); }
    .stat-value {
      font-family: 'Syne', sans-serif;
      font-size: 2rem;
      font-weight: 700;
      line-height: 1;
    }
    .stat-label { color: var(--text-muted); font-size: 12.5px; margin-top: 4px; }

    /* ════════════ CARD ════════════ */
    .admin-card {
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      overflow: hidden;
    }
    .admin-card-header {
      padding: 18px 24px;
      border-bottom: 1px solid var(--border);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .admin-card-title {
      font-family: 'Syne', sans-serif;
      font-weight: 700;
      font-size: 1rem;
    }
    .admin-card-body { padding: 0; }

    /* ════════════ TABLE ════════════ */
    .table-dark-custom {
      width: 100%;
      border-collapse: collapse;
      color: var(--text-primary);
    }
    .table-dark-custom thead th {
      background: var(--bg-surface);
      color: var(--text-muted);
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: .08em;
      padding: 12px 20px;
      border-bottom: 1px solid var(--border);
      white-space: nowrap;
    }
    .table-dark-custom tbody td {
      padding: 14px 20px;
      border-bottom: 1px solid var(--border);
      vertical-align: middle;
    }
    .table-dark-custom tbody tr:last-child td { border-bottom: none; }
    .table-dark-custom tbody tr:hover td { background: var(--bg-hover); }

    /* ════════════ BADGES ════════════ */
    .badge-type {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 11.5px;
      font-weight: 600;
      letter-spacing: .02em;
    }
    .badge-group   { background: rgba(108,99,255,.18); color: #a59fff; }
    .badge-private { background: rgba(0,212,170,.12);  color: #3dd9bb; }

    /* ════════════ BUTTONS ════════════ */
    .btn-accent {
      background: var(--accent);
      color: #fff;
      border: none;
      border-radius: 9px;
      padding: 9px 18px;
      font-weight: 600;
      font-size: 13.5px;
      display: inline-flex; align-items: center; gap: 7px;
      cursor: pointer;
      transition: all var(--transition);
      box-shadow: 0 4px 16px var(--accent-glow);
    }
    .btn-accent:hover {
      background: #7c74ff;
      transform: translateY(-1px);
      box-shadow: 0 6px 24px var(--accent-glow);
      color: #fff;
    }
    .btn-icon {
      width: 32px; height: 32px;
      border-radius: 8px;
      border: 1px solid var(--border);
      background: transparent;
      color: var(--text-muted);
      display: inline-flex; align-items: center; justify-content: center;
      cursor: pointer;
      transition: all var(--transition);
      font-size: 13px;
    }
    .btn-icon:hover { background: var(--bg-hover); color: var(--text-primary); }
    .btn-icon.danger:hover { background: rgba(255,79,109,.15); color: var(--danger); border-color: var(--danger); }
    .btn-icon.teal:hover   { background: rgba(0,212,170,.12);  color: var(--accent2); border-color: var(--accent2); }

    /* ════════════ FILTER PILLS ════════════ */
    .filter-pills { display: flex; gap: 8px; flex-wrap: wrap; }
    .pill {
      padding: 6px 16px;
      border-radius: 20px;
      font-size: 12.5px;
      font-weight: 600;
      border: 1px solid var(--border);
      color: var(--text-muted);
      text-decoration: none;
      transition: all var(--transition);
    }
    .pill:hover { background: var(--bg-hover); color: var(--text-primary); }
    .pill.active { background: var(--accent); border-color: var(--accent); color: #fff; box-shadow: 0 2px 12px var(--accent-glow); }

    /* ════════════ MODAL ════════════ */
    /* Above #sidebar (1000) and above #toast-container empty hit-area */
    .modal-backdrop { z-index: 1040 !important; }
    .modal { z-index: 1055 !important; }

    .modal-content {
      background: var(--bg-card) !important;
      border: 1px solid var(--border) !important;
      border-radius: var(--radius) !important;
      color: var(--text-primary) !important;
    }
    .modal-header {
      border-bottom: 1px solid var(--border) !important;
      padding: 20px 24px !important;
    }
    .modal-body { padding: 24px !important; }
    .modal-footer {
      border-top: 1px solid var(--border) !important;
      padding: 16px 24px !important;
    }
    .modal-title {
      font-family: 'Syne', sans-serif;
      font-weight: 700;
    }
    .btn-close { filter: invert(1); }
    .form-control, .form-select {
      background: var(--bg-surface) !important;
      border: 1px solid var(--border) !important;
      color: var(--text-primary) !important;
      border-radius: 9px !important;
    }
    .form-control:focus, .form-select:focus {
      border-color: var(--accent) !important;
      box-shadow: 0 0 0 3px var(--accent-glow) !important;
    }
    .form-control::placeholder { color: var(--text-muted) !important; }
    .form-label { color: var(--text-muted); font-size: 12.5px; font-weight: 600; text-transform: uppercase; letter-spacing: .06em; }

    /* ════════════ TOAST ════════════ */
    #toast-container {
      position: fixed; bottom: 24px; right: 24px;
      z-index: 1080;
      display: flex; flex-direction: column; gap: 10px;
      pointer-events: none;
    }
    .toast-msg {
      pointer-events: auto;
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 14px 18px;
      min-width: 260px;
      display: flex; align-items: center; gap: 12px;
      animation: slideInRight .3s ease forwards;
      box-shadow: 0 8px 32px rgba(0,0,0,.4);
    }
    .toast-msg.success { border-left: 3px solid var(--accent2); }
    .toast-msg.error   { border-left: 3px solid var(--danger); }
    @keyframes slideInRight {
      from { transform: translateX(40px); opacity: 0; }
      to   { transform: translateX(0);    opacity: 1; }
    }

    /* ════════════ INVITE CODE ════════════ */
    .invite-code-box {
      background: var(--bg-surface);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 12px 18px;
      font-family: 'Courier New', monospace;
      font-size: 1.1rem;
      font-weight: 700;
      letter-spacing: .2em;
      color: var(--accent2);
      display: inline-block;
    }

    /* ════════════ DETAIL GRID ════════════ */
    .detail-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 16px;
    }
    .detail-item {}
    .detail-item-label { font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: var(--text-muted); font-weight: 600; margin-bottom: 6px; }
    .detail-item-value { font-size: 15px; font-weight: 500; }

    /* ════════════ FOOTER ════════════ */
    #page-footer {
      padding: 20px 32px;
      border-top: 1px solid var(--border);
      text-align: center;
      color: var(--text-muted);
      font-size: 12.5px;
    }

    /* ════════════ SCROLLBAR ════════════ */
    ::-webkit-scrollbar { width: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: rgba(255,255,255,.1); border-radius: 3px; }

    /* ════════════ DATATABLES OVERRIDE ════════════ */
    .dataTables_wrapper .dataTables_length select,
    .dataTables_wrapper .dataTables_filter input {
      background: var(--bg-surface) !important;
      border: 1px solid var(--border) !important;
      color: var(--text-primary) !important;
      border-radius: 8px !important;
      padding: 6px 10px !important;
    }
    .dataTables_wrapper .dataTables_info,
    .dataTables_wrapper .dataTables_length label,
    .dataTables_wrapper .dataTables_filter label { color: var(--text-muted) !important; }
    .dataTables_wrapper .paginate_button {
      background: var(--bg-surface) !important;
      border: 1px solid var(--border) !important;
      color: var(--text-muted) !important;
      border-radius: 7px !important;
    }
    .dataTables_wrapper .paginate_button.current,
    .dataTables_wrapper .paginate_button:hover {
      background: var(--accent) !important;
      border-color: var(--accent) !important;
      color: #fff !important;
    }

    /* ════════════ RESPONSIVE ════════════ */
    @media (max-width: 768px) {
      #sidebar { transform: translateX(-100%); }
      #sidebar.open { transform: translateX(0); }
      #main-wrapper { margin-left: 0; }
      #page-content { padding: 20px 16px; }
    }
  </style>
</head>
<body>

<%-- Load JS before page content: child JSPs (room-list, room-detail) embed inline scripts
     that use $ / bootstrap.Modal; if these tags stay at the bottom, those scripts throw
     "$ is not defined" and never define openCreateModal / DataTable init. --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
<script>window.__CTX = '${pageContext.request.contextPath}';</script>

<!-- ══════════ SIDEBAR ══════════ -->
<jsp:include page="sidebar.jsp" />

<!-- ══════════ MAIN WRAPPER ══════════ -->
<div id="main-wrapper">

  <!-- HEADER -->
  <jsp:include page="header.jsp" />

  <!-- CONTENT -->
  <main id="page-content">
    <jsp:include page="${contentPage}" />
  </main>

  <!-- FOOTER -->
  <jsp:include page="footer.jsp" />
</div>

<!-- Toast container -->
<div id="toast-container"></div>

<script>
  // ── Global toast utility ──
  function showToast(message, type = 'success') {
    const icon = type === 'success' ? '✓' : '✕';
    const div = document.createElement('div');
    div.className = 'toast-msg ' + type;
    div.innerHTML = `<span style="font-size:1.1rem">${icon}</span><span>${message}</span>`;
    document.getElementById('toast-container').appendChild(div);
    setTimeout(() => div.remove(), 3500);
  }

  // ── Confirm modal helper ──
  function confirmAction(message, callback) {
    if (confirm(message)) callback();
  }
</script>

</body>
</html>
