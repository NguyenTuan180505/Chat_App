package com.tuan.chatapp.model;

import jakarta.persistence.*;

@Entity
public class RoomMember {
    @Id @GeneratedValue
    private Long id;

    private Long roomId;
    private Long userId;
}
