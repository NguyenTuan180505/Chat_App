package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.request.LoginRequest;
import com.tuan.chatapp.dto.request.RegisterRequest;
import com.tuan.chatapp.dto.response.LoginResponse;
import com.tuan.chatapp.mapper.UserMapper;
import com.tuan.chatapp.model.Role;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.RoleRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Service
@RequiredArgsConstructor
public class AuthService implements IAuthService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final RoleRepository roleRepo;

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

    @Override
    public LoginResponse login(LoginRequest request) {
        User user = userRepo.findByUsername(request.getUsername())
                .orElseThrow(() -> new UsernameNotFoundException("Username không tồn tại"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Username hoặc mật khẩu không đúng");
        }

        authenticateUser(user);

        return LoginResponse.builder()
                .success(true)
                .message("Đăng nhập thành công")
                .username(user.getUsername())
                .fullName(user.getFullName())
                .redirect("/chat")
                .build();
    }

    private void authenticateUser(User user) {
        UserDetails userDetails = buildUserDetails(user);
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                userDetails, null, userDetails.getAuthorities());

        SecurityContextHolder.getContext().setAuthentication(authentication);
        saveSecurityContextToSession(SecurityContextHolder.getContext());
    }

    private UserDetails buildUserDetails(User user)
    {
        Role role = roleRepo.findById(user.getRoleId())
                .orElseThrow(()-> new RuntimeException("Không tìm thấy role"));
        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .roles(role.getRoleName() != null ? role.getRoleName().name() : "USER")
                .build();
    }

    private void saveSecurityContextToSession(SecurityContext context) {
        HttpServletRequest request = ((ServletRequestAttributes)
                RequestContextHolder.currentRequestAttributes()).getRequest();
        HttpSession session = request.getSession(true);
        session.setAttribute(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
    }
}
