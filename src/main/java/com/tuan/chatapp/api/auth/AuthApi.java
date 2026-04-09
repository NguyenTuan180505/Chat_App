package com.tuan.chatapp.api.auth;


import com.tuan.chatapp.dto.request.RegisterRequest;
import com.tuan.chatapp.service.IAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthApi {

    private final IAuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@ModelAttribute RegisterRequest request){
        try{
            authService.register(request);
            return ResponseEntity.ok(Map.of("success", true, "message", "Đăng kí tài khoản thành công"));
        } catch (Exception e){
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
