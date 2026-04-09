package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.request.RegisterRequest;

public interface IAuthService {
    void register(RegisterRequest request);
}
