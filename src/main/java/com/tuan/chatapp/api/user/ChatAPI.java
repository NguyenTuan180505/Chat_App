package com.tuan.chatapp.api.user;


import com.tuan.chatapp.dto.request.MessageRequest; // nếu cần
import com.tuan.chatapp.dto.response.MessageResponse;
import com.tuan.chatapp.service.IChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatAPI {

    private final IChatService chatService;

    // ─── JOIN GROUP ROOM BY CODE ─────────────────────────────────────────────
    @PostMapping("/join-room")
    public ResponseEntity<?> joinRoom(
            @RequestBody Map<String, String> body,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.joinRoom(body, userDetails);
    }

    // ─── FIND USER BY PHONE ─────────────────────────────────────────────────
    @GetMapping("/find-user")
    public ResponseEntity<?> findUserByPhone(
            @RequestParam String phone,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.findUserByPhone(phone, userDetails);
    }

    // ─── CREATE PRIVATE ROOM ────────────────────────────────────────────────
    @PostMapping("/create-private")
    public ResponseEntity<?> createPrivateRoom(
            @RequestBody Map<String, Long> body,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.createPrivateRoom(body, userDetails);
    }

    // ─── GET CHAT HISTORY ───────────────────────────────────────────────────
    @GetMapping("/history/{roomId}")
    public ResponseEntity<?> getHistory(
            @PathVariable Long roomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.getHistory(roomId, userDetails);
    }

    // ─── GET MY ROOMS ───────────────────────────────────────────────────────
    @GetMapping("/my-rooms")
    public ResponseEntity<?> getMyRooms(@AuthenticationPrincipal UserDetails userDetails) {
        return chatService.getMyRooms(userDetails);
    }
}
