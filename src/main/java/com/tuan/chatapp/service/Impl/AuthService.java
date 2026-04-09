package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.request.RegisterRequest;
import com.tuan.chatapp.mapper.UserMapper;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IAuthService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService implements IAuthService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    @Transactional
    @Override
    public void register(RegisterRequest request) {

        if (userRepo.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepo.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone already exists");
        }

        User user = userMapper.toEntity(request);

        user.setPassword(passwordEncoder.encode(request.getPassword()));

        userRepo.save(user);
    }
}
