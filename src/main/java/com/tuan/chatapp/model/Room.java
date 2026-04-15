package com.tuan.chatapp.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
public class Room {
    @Id @GeneratedValue
    private Long id;

    private String name;
    private String type; // GROUP / PRIVATE

    private String inviteCode;

    private Long createdBy;

    private LocalDateTime createdAt = LocalDateTime.now();

}
