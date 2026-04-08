package com.tuan.chatapp.config;

import com.tuan.chatapp.Security.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.parameters.P;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // ========================
    // 1. Password Encoder
    // ========================
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService(CustomUserDetailsService service){
        return service;
    }


    // ========================
    // 2. Security Config
    // ========================git branch -a
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                // ❌ Tắt CSRF (vì dùng WebSocket + API)
                .csrf(csrf -> csrf.disable())

                // ❌ Tắt form login mặc định
                .formLogin(form -> form.disable())

                // ❌ Tắt HTTP Basic
                .httpBasic(basic -> basic.disable())

                // ✅ Phân quyền
                .authorizeHttpRequests(auth -> auth
                        // cho phép truy cập public
                        .requestMatchers(
                                "/api/auth/**",     // login, register
                                "/ws/**",           // websocket endpoint
                                "/topic/**",        // subscribe
                                "/app/**"
                        ).permitAll()
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")

                        .requestMatchers("/api/user/**").hasAnyRole("USER", "ADMIN")

                        // các request khác phải login
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}