package com.tuan.chatapp.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Message {
    @Id @GeneratedValue
    private Long id;

    private Long senderId;
    private Long roomId;
    private String content;

    private LocalDateTime createdAt = LocalDateTime.now();
}