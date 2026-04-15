// UserDto.java
package com.tuan.chatapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String username;
    private String fullName;
    private String phone;
    private String roleName;        // hiển thị tên role thay vì roleId
    private String description;     // mô tả role (tùy chọn)
}