package com.tuan.chatapp.api.user;

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

    @PostMapping("/join-room")
    public ResponseEntity<?> joinRoom(
            @RequestBody Map<String, String> body,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.joinRoom(body, userDetails);
    }

    @GetMapping("/find-user")
    public ResponseEntity<?> findUserByPhone(
            @RequestParam String phone,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.findUserByPhone(phone, userDetails);
    }

    @PostMapping("/create-private")
    public ResponseEntity<?> createPrivateRoom(
            @RequestBody Map<String, Long> body,
            @AuthenticationPrincipal UserDetails userDetails) {
        return chatService.createPrivateRoom(body, userDetails);
    }

    @GetMapping("/history/{roomId}")
    public ResponseEntity<?> getHistory(
            @PathVariable Long roomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        System.out.println("Ten User "+ userDetails.getUsername());
        return chatService.getHistory(roomId, userDetails);
    }

    @GetMapping("/my-rooms")
    public ResponseEntity<?> getMyRooms(@AuthenticationPrincipal UserDetails userDetails) {
        return chatService.getMyRooms(userDetails);
    }
}
