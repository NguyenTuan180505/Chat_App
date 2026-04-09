package com.tuan.chatapp.dto.request;


import lombok.Data;

@Data
public class RegisterRequest {

//    @NotBlank
    private String username;
    private String password;
    private String fullName;
    private String phone;
}
