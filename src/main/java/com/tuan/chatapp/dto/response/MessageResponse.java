package com.tuan.chatapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class MessageResponse {
    private Long id;
    private Long senderId;
    private String senderUsername;
    private Long roomId;
    private String content;
    private LocalDateTime createdAt;
}
