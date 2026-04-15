package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.UserDto;
import com.tuan.chatapp.model.Role;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.RoleRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IUserAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserAdminServiceImpl implements IUserAdminService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public List<UserDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng với ID: " + userId));

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated()
                && !"anonymousUser".equals(auth.getName())
                && auth.getName().equals(user.getUsername())) {
            throw new RuntimeException("Không thể xóa chính tài khoản của bạn!");
        }
        Role role = roleRepository.findById(user.getRoleId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy role"));

        if ("ADMIN".equalsIgnoreCase(role.getRoleName().name())) {
            throw new RuntimeException("Không thể xóa tài khoản admin");
        }

        userRepository.delete(user);
    }

    private UserDto convertToDto(User user) {
        String roleName = "USER";
        String description = "";

        if (user.getRoleId() != null) {
            Role role = roleRepository.findById(user.getRoleId()).orElse(null);
            if (role != null) {
                roleName = role.getRoleName().name();
                description = role.getDescription() != null ? role.getDescription() : "";
            }
        }

        return new UserDto(
                user.getId(),
                user.getUsername(),
                user.getFullName(),
                user.getPhone(),
                roleName,
                description
        );
    }
}