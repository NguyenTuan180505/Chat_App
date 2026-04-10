package com.tuan.chatapp.controller;

import com.tuan.chatapp.Security.CustomUserDetails;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatController {

    @GetMapping("/chat")
    public String chatPage(Model model) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.isAuthenticated()) {
            String username = authentication.getName();   // username/login

//             Nếu bạn có Custom UserDetails với fullName, dùng cách này:
             Object principal = authentication.getPrincipal();
             if (principal instanceof CustomUserDetails user) {
                 model.addAttribute("fullName", user.getFulName());
             } else {
                 model.addAttribute("fullName", username);
             }

            model.addAttribute("username", username);
//            model.addAttribute("fullName", username);   // tạm thời dùng username làm fullName
        }

        return "chat/chat";   // tên view của bạn
    }
}