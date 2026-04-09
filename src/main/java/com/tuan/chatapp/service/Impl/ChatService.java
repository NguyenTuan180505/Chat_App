package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.response.MessageResponse;
import com.tuan.chatapp.model.Room;
import com.tuan.chatapp.model.RoomMember;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.RoomMemberRepository;
import com.tuan.chatapp.repository.RoomRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IChatService;
import com.tuan.chatapp.service.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChatService implements IChatService {

    private final RoomRepository roomRepo;
    private final RoomMemberRepository roomMemberRepo;
    private final UserRepository userRepo;
    private final IMessageService messageService;

    @Override
    public ResponseEntity<?> joinRoom(Map<String, String> body, UserDetails userDetails) {
        String roomCode = body.get("roomCode");
        if (roomCode == null || roomCode.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mã phòng không được trống"));
        }

        Optional<Room> optRoom = roomRepo.findByName(roomCode.trim());
        if (optRoom.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("message", "Không tìm thấy phòng với mã: " + roomCode));
        }
        Room room = optRoom.get();

        if (!"GROUP".equals(room.getType())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Phòng này không phải nhóm chat"));
        }

        User user = userRepo.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        boolean alreadyMember = roomMemberRepo.existsByRoomIdAndUserId(room.getId(), user.getId());
        if (alreadyMember) {
            return ResponseEntity.ok(Map.of(
                    "message", "Bạn đã là thành viên của phòng này",
                    "roomId", room.getId(),
                    "roomName", room.getName()
            ));
        }

        RoomMember member = new RoomMember();
        member.setRoomId(room.getId());
        member.setUserId(user.getId());
        roomMemberRepo.save(member);

        return ResponseEntity.ok(Map.of(
                "message", "Tham gia phòng thành công",
                "roomId", room.getId(),
                "roomName", room.getName()
        ));
    }

    @Override
    public ResponseEntity<?> findUserByPhone(String phone, UserDetails userDetails) {

        Optional<User> optUser = userRepo.findByPhone(phone);

        if (optUser.isEmpty()) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", "Không tìm thấy người dùng với số điện thoại này"));
        }

        User found = optUser.get();

        if (found.getUsername().equals(userDetails.getUsername())) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Đây là số điện thoại của bạn"));
        }

        return ResponseEntity.ok(Map.of(
                "id", found.getId(),
                "username", found.getUsername(),
                "fullName", found.getFullName()
        ));
    }
    @Override
    public ResponseEntity<?> createPrivateRoom(Map<String, Long> body, UserDetails userDetails) {
        Long targetUserId = body.get("targetUserId");
        if (targetUserId == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "targetUserId không được trống"));
        }

        User me = userRepo.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        User target = userRepo.findById(targetUserId)
                .orElseThrow(() -> new RuntimeException("Target user not found"));

        Optional<Room> existingRoom = findPrivateRoom(me.getId(), target.getId());
        if (existingRoom.isPresent()) {
            Room room = existingRoom.get();
            return ResponseEntity.ok(Map.of(
                    "message", "Đoạn chat đã tồn tại",
                    "roomId", room.getId(),
                    "targetName", target.getFullName()
            ));
        }

        // Tạo phòng mới
        Room room = new Room();
        room.setName("PRIVATE_" + me.getId() + "_" + target.getId());
        room.setType("PRIVATE");
        room.setCreatedBy(me.getId());
        roomRepo.save(room);

        // Thêm thành viên
        RoomMember m1 = new RoomMember();
        m1.setRoomId(room.getId());
        m1.setUserId(me.getId());
        roomMemberRepo.save(m1);

        RoomMember m2 = new RoomMember();
        m2.setRoomId(room.getId());
        m2.setUserId(target.getId());
        roomMemberRepo.save(m2);

        return ResponseEntity.ok(Map.of(
                "message", "Tạo đoạn chat thành công",
                "roomId", room.getId(),
                "targetName", target.getFullName()
        ));
    }

    @Override
    public ResponseEntity<?> getHistory(Long roomId, UserDetails userDetails) {
        User me = userRepo.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        boolean isMember = roomMemberRepo.existsByRoomIdAndUserId(roomId, me.getId());
        if (!isMember) {
            return ResponseEntity.status(403).body(Map.of("message", "Bạn không có quyền xem phòng này"));
        }

        List<MessageResponse> messages = messageService.getMessagesByRoom(roomId);
        return ResponseEntity.ok(messages);
    }

    @Override
    public ResponseEntity<?> getMyRooms(UserDetails userDetails) {
        User me = userRepo.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<RoomMember> memberships = roomMemberRepo.findByUserId(me.getId());
        List<Long> roomIds = memberships.stream().map(RoomMember::getRoomId).toList();
        List<Room> rooms = roomRepo.findAllById(roomIds);

        List<Map<String, Object>> result = rooms.stream().map(r -> Map.<String, Object>of(
                "id", r.getId(),
                "name", r.getName(),
                "type", r.getType()
        )).toList();

        return ResponseEntity.ok(result);
    }

    // Helper method (giữ nguyên trong Service)
    private Optional<Room> findPrivateRoom(Long userId1, Long userId2) {
        List<RoomMember> rooms1 = roomMemberRepo.findByUserId(userId1);
        List<RoomMember> rooms2 = roomMemberRepo.findByUserId(userId2);

        List<Long> roomIds1 = rooms1.stream().map(RoomMember::getRoomId).toList();
        List<Long> roomIds2 = rooms2.stream().map(RoomMember::getRoomId).toList();

        return roomIds1.stream()
                .filter(roomIds2::contains)
                .map(roomRepo::findById)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .filter(r -> "PRIVATE".equals(r.getType()))
                .findFirst();
    }
}