package com.tuan.chatapp.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class User {
    @Id @GeneratedValue
    private Long id;

    private String username;
    private String password;
    private String fullName;
    private String phone;

    private Long roleId;
}
