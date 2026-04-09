package com.tuan.chatapp.Security;

import com.tuan.chatapp.model.Role;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.RoleRepository;
import com.tuan.chatapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        Role role = roleRepository.findById(user.getRoleId())
                .orElseThrow(()-> new RuntimeException("Role not found"));
        return new CustomUserDetails(user, role.getRoleName().name());
    }
}
