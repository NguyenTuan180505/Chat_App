package com.tuan.chatapp.mapper;

import com.tuan.chatapp.dto.request.RegisterRequest;
import com.tuan.chatapp.model.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(target = "roleId", expression = "java(2L)")
    User toEntity(RegisterRequest request);
}
