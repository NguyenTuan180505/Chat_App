package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.*;
import com.tuan.chatapp.dto.request.CreateRoomRequest;
import com.tuan.chatapp.dto.response.InviteCodeResponse;
import com.tuan.chatapp.model.Room;
import com.tuan.chatapp.model.RoomMember;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.RoomMemberRepository;
import com.tuan.chatapp.repository.RoomRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.RoomAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class RoomAdminServiceImpl implements RoomAdminService {

    private final RoomRepository roomRepository;
    private final RoomMemberRepository roomMemberRepository;
    private final UserRepository userRepository;

    @Override
    public List<RoomDto> getAllRoomsByType(String type) {
        List<Room> rooms = (type == null || type.trim().isEmpty())
                ? roomRepository.findAll()
                : roomRepository.findByType(type.toUpperCase());

        return rooms.stream().map(this::convertToDto).collect(Collectors.toList());
    }

    @Override
    public RoomDto createRoom(CreateRoomRequest request) {
        Room room = new Room();
        room.setName(request.getName());
        room.setType(request.getType().toUpperCase());
        room.setCreatedBy(request.getCreatedBy());

        Room savedRoom = roomRepository.save(room);
        return convertToDto(savedRoom);
    }

    @Override
    public void deleteRoom(Long roomId) {
        if (!roomRepository.existsById(roomId)) {
            throw new RuntimeException("Không tìm thấy room");
        }
        roomRepository.deleteById(roomId);
    }

    @Override
    public RoomDto getRoomDetail(Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy room"));
        return convertToDto(room);
    }

    @Override
    public List<RoomMemberDto> getRoomMembers(Long roomId) {
        List<RoomMember> members = roomMemberRepository.findByRoomId(roomId);

        return members.stream().map(member -> {
            User user = userRepository.findById(member.getUserId())
                    .orElse(null);
            return RoomMemberDto.builder()
                    .userId(member.getUserId())
                    .username(user != null ? user.getUsername() : null)
                    .fullName(user != null ? user.getFullName() : null)
                    .phone(user != null ? user.getPhone() : null)
                    .build();
        }).collect(Collectors.toList());
    }

    @Override
    public RoomMemberDto addMemberByPhone(Long roomId, String phone) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy room"));

        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user có số điện thoại: " + phone));

        // Kiểm tra đã tồn tại chưa
        if (roomMemberRepository.findByRoomIdAndUserId(roomId, user.getId()).isPresent()) {
            throw new RuntimeException("User đã là thành viên của room này");
        }

        RoomMember member = new RoomMember();
        member.setRoomId(roomId);
        member.setUserId(user.getId());

        roomMemberRepository.save(member);

        return RoomMemberDto.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .build();
    }

    @Override
    public void removeMember(Long roomId, Long userId) {
        roomMemberRepository.deleteByRoomIdAndUserId(roomId, userId);
    }

    @Override
    public InviteCodeResponse generateInviteCode(Long roomId) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy room"));

        String inviteCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        room.setInviteCode(inviteCode);
        roomRepository.save(room);

        return InviteCodeResponse.builder()
                .roomId(roomId)
                .inviteCode(inviteCode)
                .build();
    }

    private RoomDto convertToDto(Room room) {
        return RoomDto.builder()
                .id(room.getId())
                .name(room.getName())
                .type(room.getType())
                .createdBy(room.getCreatedBy())
                .inviteCode(room.getInviteCode())
                .createdAt(room.getCreatedAt())
                .build();
    }
}