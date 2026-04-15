package com.tuan.chatapp.dto.request;

import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class UpdateRoomRequest {
    private String name;
//    private String type;
}