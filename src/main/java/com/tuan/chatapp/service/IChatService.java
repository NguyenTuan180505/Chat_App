package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.response.MessageResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.List;
import java.util.Map;

public interface IChatService {

    ResponseEntity<?> joinRoom(Map<String, String> body, UserDetails userDetails);

    ResponseEntity<?> findUserByPhone(String phone, UserDetails userDetails);

    ResponseEntity<?> createPrivateRoom(Map<String, Long> body, UserDetails userDetails);

    ResponseEntity<?> getHistory(Long roomId, UserDetails userDetails);

    ResponseEntity<?> getMyRooms(UserDetails userDetails);
}
