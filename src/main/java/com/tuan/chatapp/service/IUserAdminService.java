package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.UserDto;

import java.util.List;

public interface IUserAdminService {
    List<UserDto> getAllUsers();

    void deleteUser(Long userId);
}
