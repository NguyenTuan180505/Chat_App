package com.tuan.chatapp.controller;

import ch.qos.logback.core.model.Model;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ChatController {   // Đây là controller render trang
    @GetMapping("/chat")
    public String chatPage(Model model) {
        // add username, fullName vào model
        return "chat/chat";   // chat.jsp
    }
}
