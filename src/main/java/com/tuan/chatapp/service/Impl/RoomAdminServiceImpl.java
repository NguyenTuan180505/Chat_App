package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.*;
import com.tuan.chatapp.dto.request.CreateRoomRequest;
import com.tuan.chatapp.dto.request.UpdateRoomRequest;
import com.tuan.chatapp.dto.response.InviteCodeResponse;
import com.tuan.chatapp.mapper.MessageMapper;
import com.tuan.chatapp.model.Room;
import com.tuan.chatapp.model.RoomMember;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.model.Message;
import com.tuan.chatapp.repository.MessageRepository;
import com.tuan.chatapp.repository.RoomMemberRepository;
import com.tuan.chatapp.repository.RoomRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IRoomAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class RoomAdminServiceImpl implements IRoomAdminService {

    private final RoomRepository roomRepository;
    private final RoomMemberRepository roomMemberRepository;
    private final UserRepository userRepository;
    private final MessageRepository messageRepository;
    private final MessageMapper messageMapper;

    @Override
    public List<RoomDto> getAllRoomsByType(String type) {
        List<Room> rooms = (type == null || type.trim().isEmpty())
                ? roomRepository.findAll()
                : roomRepository.findByType(type.toUpperCase());

        return rooms.stream().map(this::convertToDto).collect(Collectors.toList());
    }

    @Override
    public RoomDto createRoom(CreateRoomRequest request, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Room room = new Room();
        room.setName(request.getName());
        room.setType(request.getType().toUpperCase());
        room.setCreatedBy(user.getId());

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
        // Tìm room, throw exception rõ ràng nếu không tồn tại
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phòng với ID: " + roomId));

        // Chỉ cho phép tạo mã mời với phòng GROUP
        if (!"GROUP".equals(room.getType())) {
            throw new RuntimeException("Chỉ phòng loại GROUP mới được tạo mã mời");
        }

        // Tạo invite code ngẫu nhiên (8 ký tự uppercase)
        String inviteCode = UUID.randomUUID()
                .toString()
                .replace("-", "")           // loại bỏ dấu gạch ngang
                .substring(0, 8)
                .toUpperCase();

        // Cập nhật và lưu
        room.setInviteCode(inviteCode);
        roomRepository.save(room);

        // Trả về response
        return InviteCodeResponse.builder()
                .roomId(roomId)
                .inviteCode(inviteCode)
                .build();
    }

    @Override
    @Transactional
    public RoomDto updateRoom(Long roomId, UpdateRoomRequest request) {
        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room không tồn tại"));

        if (request.getName() != null && !request.getName().isBlank())
            room.setName(request.getName());
        return convertToDto(roomRepository.save(room));
    }

    @Override
    public List<MessageDto> getRoomMessages(Long roomId) {
        roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room không tồn tại"));

        List<Message> messages = messageRepository.findByRoomIdOrderByCreatedAtAsc(roomId);
        if (messages.isEmpty()) return Collections.emptyList();

        // Load tất cả sender 1 lần duy nhất → tránh N+1 query
        Set<Long> senderIds = messages.stream()
                .map(Message::getSenderId)
                .collect(Collectors.toSet());

        Map<Long, User> userMap = userRepository.findAllById(senderIds)
                .stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        return messages.stream()
                .map(message -> {
                    MessageDto dto = messageMapper.toDto(message);
                    User sender = userMap.get(message.getSenderId());
                    if (sender != null) {
                        dto.setSenderUsername(sender.getUsername());
                        dto.setSenderFullName(sender.getFullName());
                    }
                    return dto;
                })
                .collect(Collectors.toList());
    }

    private RoomDto convertToDto(Room room) {
        User user = userRepository.findById(room.getCreatedBy())
                    .orElseThrow(()-> new RuntimeException("Lỗi không tìm thấy người dùng"));
        return RoomDto.builder()
                .id(room.getId())
                .name(room.getName())
                .type(room.getType())
                .createdBy(room.getCreatedBy())
                .createdName(user.getFullName())
                .inviteCode(room.getInviteCode())
                .createdAt(room.getCreatedAt())
                .build();
    }
}