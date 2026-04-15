package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.request.MessageRequest;
import com.tuan.chatapp.dto.response.MessageResponse;
import com.tuan.chatapp.mapper.MessageMapper;
import com.tuan.chatapp.model.Message;
import com.tuan.chatapp.model.Room;
import com.tuan.chatapp.model.RoomMember;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.MessageRepository;
import com.tuan.chatapp.repository.RoomMemberRepository;
import com.tuan.chatapp.repository.RoomRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements IMessageService {

    private final MessageRepository messageRepository;
    private final MessageMapper messageMapper;
    private final UserRepository userRepository;
    private final RoomRepository roomRepository;
    private final RoomMemberRepository roomMemberRepository;

    @Override
    @Transactional
    public MessageResponse saveMessage(MessageRequest messageRequest, String username) {

        // 1. Lấy sender
        User sender = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Không thấy user"));

        // 2. Tìm room
        Room room = roomRepository.findById(messageRequest.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room không tồn tại"));

        // 3. ✅ Kiểm tra sender có trong phòng không
        List<RoomMember> members = roomMemberRepository.findByRoomId(room.getId());

        boolean isMember = members.stream()
                .anyMatch(m -> m.getUserId().equals(sender.getId()));

        if (!isMember) {
            throw new RuntimeException("Bạn không phải thành viên của phòng này");
        }

        // 4. Tạo message
        Message message = messageMapper.toEntity(messageRequest);
        message.setSenderId(sender.getId());
        message.setCreatedAt(LocalDateTime.now());

        // 5. Nếu là phòng PRIVATE → tìm receiver
        User receiver = null;

        if ("PRIVATE".equals(room.getType())) {
            receiver = members.stream()
                    .filter(m -> !m.getUserId().equals(sender.getId()))
                    .findFirst()
                    .map(m -> userRepository.findById(m.getUserId()).orElse(null))
                    .orElse(null);
        }

        // 6. Save message
        Message savedMessage = messageRepository.save(message);

        // 7. Map response
        MessageResponse response = messageMapper.toResponse(savedMessage);
        response.setSenderName(sender.getFullName());
        response.setSenderUsername(sender.getUsername());

        if (receiver != null) {
            response.setReceiverUsername(receiver.getUsername());
            response.setReceiverName(receiver.getFullName());
        }

        return response;
    }

    @Override
    public List<MessageResponse> getMessagesByRoom(Long roomId) {
        return messageRepository.findByRoomIdOrderByCreatedAtAsc(roomId).stream()
                .map(m -> {
                    User sender = userRepository.findById(m.getSenderId()).orElse(null);
                    return MessageResponse.builder()
                            .id(m.getId())
                            .senderName(sender != null ? sender.getFullName() : "Unknown")
                            .senderUsername(sender.getUsername())
                            .roomId(m.getRoomId())
                            .content(m.getContent())
                            .createdAt(m.getCreatedAt())
                            .build();
                }).toList();
    }
}

