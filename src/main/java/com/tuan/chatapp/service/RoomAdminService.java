package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.*;
import com.tuan.chatapp.dto.request.CreateRoomRequest;
import com.tuan.chatapp.dto.response.InviteCodeResponse;

import java.util.List;

public interface RoomAdminService {

    List<RoomDto> getAllRoomsByType(String type); // null = tất cả

    RoomDto createRoom(CreateRoomRequest request);

    void deleteRoom(Long roomId);

    RoomDto getRoomDetail(Long roomId);

    List<RoomMemberDto> getRoomMembers(Long roomId);

    RoomMemberDto addMemberByPhone(Long roomId, String phone);

    void removeMember(Long roomId, Long userId);

    InviteCodeResponse generateInviteCode(Long roomId);
}