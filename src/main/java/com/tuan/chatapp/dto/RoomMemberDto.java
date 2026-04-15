package com.tuan.chatapp.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoomMemberDto {
    private Long userId;
    private String username;
    private String fullName;
    private String phone;
}
