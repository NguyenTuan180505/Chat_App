package com.tuan.chatapp.api.admin;

import com.tuan.chatapp.dto.*;
import com.tuan.chatapp.dto.request.AddMemberRequest;
import com.tuan.chatapp.dto.request.CreateRoomRequest;
import com.tuan.chatapp.dto.request.UpdateRoomRequest;
import com.tuan.chatapp.dto.response.InviteCodeResponse;
import com.tuan.chatapp.service.IRoomAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/rooms")
@RequiredArgsConstructor
public class RoomAdminApi {

    private final IRoomAdminService roomAdminService;

    @GetMapping
    public ResponseEntity<List<RoomDto>> getAllRooms(@RequestParam(required = false) String type) {
        return ResponseEntity.ok(roomAdminService.getAllRoomsByType(type));
    }

    @GetMapping("/{roomId}")
    public ResponseEntity<RoomDto> getRoomDetail(@PathVariable Long roomId) {
        return ResponseEntity.ok(roomAdminService.getRoomDetail(roomId));
    }

    @PostMapping
    public ResponseEntity<RoomDto> createRoom(@RequestBody CreateRoomRequest request) {
        return ResponseEntity.ok(roomAdminService.createRoom(request));
    }

    @DeleteMapping("/{roomId}")
    public ResponseEntity<Void> deleteRoom(@PathVariable Long roomId) {
        roomAdminService.deleteRoom(roomId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{roomId}/members")
    public ResponseEntity<List<RoomMemberDto>> getRoomMembers(@PathVariable Long roomId) {
        return ResponseEntity.ok(roomAdminService.getRoomMembers(roomId));
    }

    @PostMapping("/{roomId}/members")
    public ResponseEntity<RoomMemberDto> addMember(@PathVariable Long roomId,
                                                   @RequestBody AddMemberRequest request) {
        return ResponseEntity.ok(roomAdminService.addMemberByPhone(roomId, request.getPhone()));
    }

    @DeleteMapping("/{roomId}/members/{userId}")
    public ResponseEntity<Void> removeMember(@PathVariable Long roomId, @PathVariable Long userId) {
        roomAdminService.removeMember(roomId, userId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{roomId}/invite-code")
    public ResponseEntity<InviteCodeResponse> generateInviteCode(@PathVariable Long roomId) {
        return ResponseEntity.ok(roomAdminService.generateInviteCode(roomId));
    }

    @PutMapping("/{roomId}")
    public ResponseEntity<RoomDto> updateRoom(@PathVariable Long roomId,
                                              @RequestBody UpdateRoomRequest request) {
        return ResponseEntity.ok(roomAdminService.updateRoom(roomId, request));
    }

}