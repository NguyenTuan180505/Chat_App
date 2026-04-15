package com.tuan.chatapp.controller;

import com.tuan.chatapp.dto.UserDto;
import com.tuan.chatapp.service.IUserAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class UserAdminViewController {

    private final IUserAdminService userAdminService;

    /**
     * Trang danh sách người dùng
     * URL: GET /admin/users
     */
    @GetMapping({"/users", "/user"})
    public String userList(Model model) {
        List<UserDto> users = userAdminService.getAllUsers();

        model.addAttribute("users", users);
        model.addAttribute("totalUsers", users.size());
        model.addAttribute("pageTitle", "Quản lý Người dùng");
        model.addAttribute("activePage", "users");
        model.addAttribute("contentPage", "user-list.jsp");

        return "admin/layout";
    }

    /**
     * Xóa người dùng (sẽ gọi từ JSP qua AJAX hoặc form POST)
     */
    @PostMapping("/users/{id}/delete")
    public String deleteUser(@PathVariable Long id, Model model) {
        try {
            userAdminService.deleteUser(id);
            model.addAttribute("successMessage", "Xóa người dùng thành công!");
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Lỗi khi xóa người dùng: " + e.getMessage());
        }

        // Load lại danh sách sau khi xóa
        return "redirect:/admin/users";
    }
}