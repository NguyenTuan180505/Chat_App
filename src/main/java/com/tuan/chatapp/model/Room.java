package com.tuan.chatapp.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Room {
    @Id @GeneratedValue
    private Long id;

    private String name;
    private String type; // GROUP / PRIVATE

    private Long createdBy;
}
