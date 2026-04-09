package com.tuan.chatapp.config;

import com.tuan.chatapp.Security.CustomUserDetailsService;
import jakarta.servlet.DispatcherType;
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
    public UserDetailsService userDetailsService(CustomUserDetailsService service) {
        return service;
    }


    // ========================
    // 2. Security Config
    // ========================git branch -a
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/**", "/ws/**", "/topic/**", "/app/**",
                                "/css/**", "/js/**", "/images/**").permitAll()
                        .dispatcherTypeMatchers(DispatcherType.FORWARD).permitAll()  // ← fix loop chính
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/user/**").hasAnyRole("USER", "ADMIN")
                        .anyRequest().authenticated()
                )
                .formLogin(form -> form
                        .loginPage("/auth/login")
                        .loginProcessingUrl("/login")
                        .successHandler((request, response, authentication) -> {
                            // AJAX success → trả JSON thay vì redirect
                            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                                response.setContentType("application/json");
                                response.getWriter().write("{\"success\": true, \"message\": \"Login successful\", \"redirect\": \"/chat\"}");
                            } else {
                                response.sendRedirect("/chat");
                            }
                        })
                        .failureHandler((request, response, exception) -> {
                            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                                response.setContentType("application/json");
                                response.setStatus(401);
                                response.getWriter().write("{\"success\": false, \"message\": \"Invalid username or password\"}");
                            } else {
                                response.sendRedirect("/auth/login?error");
                            }
                        })
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/auth/login")
                        .permitAll()
                );

        return http.build();
    }
}