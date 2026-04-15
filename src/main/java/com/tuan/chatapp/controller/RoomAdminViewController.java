package com.tuan.chatapp.controller;

import com.tuan.chatapp.dto.RoomDto;
import com.tuan.chatapp.dto.RoomMemberDto;
import com.tuan.chatapp.service.RoomAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * View Controller for Admin Dashboard (Read-only / GET only).
 * All data mutations are handled via REST API calls from the frontend (Fetch API).
 * Maps to JSP views located in: webapp/WEB-INF/jsp/admin/
 */
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class RoomAdminViewController {

    private final RoomAdminService roomAdminService;

    /**
     * Dashboard / Room list page.
     * URL: GET /admin/rooms
     * Optional filter: ?type=GROUP or ?type=PRIVATE
     */
    @GetMapping({"/", "/rooms"})
    public String roomList(
            @RequestParam(required = false) String type,
            Model model) {

        List<RoomDto> rooms = roomAdminService.getAllRoomsByType(type);

        model.addAttribute("rooms", rooms);
        model.addAttribute("filterType", type != null ? type.toUpperCase() : "ALL");
        model.addAttribute("totalRooms", rooms.size());
        model.addAttribute("totalGroup",
                rooms.stream().filter(r -> "GROUP".equalsIgnoreCase(r.getType())).count());
        model.addAttribute("totalPrivate",
                rooms.stream().filter(r -> "PRIVATE".equalsIgnoreCase(r.getType())).count());
        model.addAttribute("pageTitle", "Quản lý Phòng Chat");
        model.addAttribute("activePage", "rooms");
        // Render within the shared admin layout (layout.jsp will include this page).
        model.addAttribute("contentPage", "room-list.jsp");

        return "admin/layout";
    }

    /**
     * Room detail page — shows room info + member list.
     * URL: GET /admin/rooms/{id}
     */
    @GetMapping("/rooms/{id}")
    public String roomDetail(@PathVariable Long id, Model model) {

        RoomDto room = roomAdminService.getRoomDetail(id);
        List<RoomMemberDto> members = roomAdminService.getRoomMembers(id);

        model.addAttribute("room", room);
        model.addAttribute("members", members);
        model.addAttribute("memberCount", members.size());
        model.addAttribute("pageTitle", "Chi tiết phòng: " + room.getName());
        model.addAttribute("activePage", "rooms");
        model.addAttribute("filterType", "ALL");
        // Needed so layout.jsp can include the correct page.
        model.addAttribute("contentPage", "room-detail.jsp");

        return "admin/layout";
    }
}