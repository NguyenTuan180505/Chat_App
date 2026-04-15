package com.tuan.chatapp.dto.request;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AddMemberRequest {
    private String phone;
}
