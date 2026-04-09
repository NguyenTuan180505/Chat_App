package com.tuan.chatapp.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class RoomMember {
    @Id @GeneratedValue
    private Long id;

    private Long roomId;
    private Long userId;
}
