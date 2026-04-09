package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.request.LoginRequest;
import com.tuan.chatapp.dto.request.RegisterRequest;
import com.tuan.chatapp.dto.response.LoginResponse;

public interface IAuthService {
    void register(RegisterRequest request);
    LoginResponse login(LoginRequest request);
}
