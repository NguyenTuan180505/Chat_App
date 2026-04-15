<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div style="margin-bottom:28px">
    <a href="${ctx}/admin/rooms" class="btn btn-link" style="color:var(--text-muted); text-decoration:none;">
        <i class="bi bi-arrow-left"></i> Quay lại danh sách phòng
    </a>
    <h1 class="page-heading" style="margin:12px 0 8px">
        <i class="bi bi-chat-left-text me-2" style="color:var(--accent)"></i>
        Lịch sử tin nhắn – <span style="color:var(--accent2)">${room.name}</span>
    </h1>
    <p style="color:var(--text-muted)">Phòng ID: #${room.id} • ${messages.size()} tin nhắn</p>
</div>

<div class="admin-card">
    <div class="admin-card-body" style="padding:20px">
        <c:choose>
            <c:when test="${empty messages}">
                <div style="text-align:center; padding:80px 20px; color:var(--text-muted)">
                    <i class="bi bi-chat-slash" style="font-size:3rem; opacity:0.3; display:block; margin-bottom:16px"></i>
                    <h5>Chưa có tin nhắn nào trong phòng này</h5>
                </div>
            </c:when>
            <c:otherwise>
                <div id="message-list" style="max-height:calc(100vh - 220px); overflow-y:auto; padding-right:10px">
                    <c:forEach var="m" items="${messages}">
                        <div style="display:flex; gap:14px; margin-bottom:20px; padding-bottom:20px; border-bottom:1px solid var(--border)">
                            <div style="width:42px; height:42px; flex-shrink:0; border-radius:10px; background:rgba(108,99,255,.2);
                                        display:flex; align-items:center; justify-content:center; font-weight:700; color:var(--accent); font-size:15px;">
                                    ${(m.senderUsername != null && m.senderUsername.length() > 0) ? m.senderUsername.substring(0,1).toUpperCase() : '?'}
                            </div>
                            <div style="flex:1; min-width:0">
                                <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px">
                                    <span style="font-weight:600; font-size:14.5px">${m.senderFullName != null ? m.senderFullName : (m.senderUsername != null ? m.senderUsername : '—')}</span>
                                    <span style="color:var(--text-muted); font-size:12px">@${m.senderUsername != null ? m.senderUsername : ''}</span>
                                    <span style="color:var(--text-muted); font-size:12px; margin-left:auto">
                                            ${m.createdAtFormatted != null ? m.createdAtFormatted : (m.createdAt != null ? m.createdAt : '')}
                                    </span>
                                </div>
                                <div style="background:var(--bg-surface); border:1px solid var(--border); border-radius:10px; padding:12px 16px; font-size:14px; line-height:1.5; word-break:break-word;">
                                        ${m.content != null ? m.content : '(Không có nội dung)'}
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Nút quay lại -->
<div style="text-align:center; margin-top:24px">
    <a href="${ctx}/admin/rooms/${room.id}" class="btn-accent">
        <i class="bi bi-arrow-left"></i> Quay lại chi tiết phòng
    </a>
</div>