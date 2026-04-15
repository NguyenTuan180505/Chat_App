package com.tuan.chatapp.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomDto {
    private Long id;
    private String name;
    private String type;
    private Long createdBy;
    private String createdName;
    private String inviteCode;
    private LocalDateTime createdAt;

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
