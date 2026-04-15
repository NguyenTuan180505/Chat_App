package com.tuan.chatapp.config;

import com.tuan.chatapp.Security.CustomUserDetailsService;
import jakarta.servlet.DispatcherType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService(CustomUserDetailsService customUserDetailsService) {
        return customUserDetailsService;
    }

    // Repository giúp lưu session sau khi login thủ công
    @Bean
    public SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())

                // Bắt buộc lưu SecurityContext vào session
                .securityContext(securityContext ->
                        securityContext.securityContextRepository(securityContextRepository())
                )

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/**", "/login", "/register",
                                "/css/**", "/js/**", "/images/**", "/favicon.ico").permitAll()

                        .requestMatchers("/ws/**", "/app/**", "/topic/**", "/queue/**").permitAll()

                        // Trang chat chỉ cần đã login
                        .requestMatchers("/chat").authenticated()

                        // Admin pages + admin APIs
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")
                        .requestMatchers("/api/user/**").hasAnyRole("USER", "ADMIN")

                        .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()

                        .anyRequest().authenticated()
                )

                .formLogin(form -> form.disable())
                .httpBasic(httpBasic -> httpBasic.disable());

        return http.build();
    }
}