package com.tuan.chatapp.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class MessageDto {
    private Long id;
    private Long roomId;
    private Long senderId;
    private String senderUsername;
    private String senderFullName;
    private String content;
    private LocalDateTime createdAt;

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "—";

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")
                .withLocale(new Locale("vi", "VN"));

        return createdAt.format(formatter);
    }
}