package com.tuan.chatapp.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class InviteCodeResponse {
    private Long roomId;
    private String inviteCode;
}
