package com.tuan.chatapp.service.Impl;

import com.tuan.chatapp.dto.request.MessageRequest;
import com.tuan.chatapp.dto.response.MessageResponse;
import com.tuan.chatapp.mapper.MessageMapper;
import com.tuan.chatapp.model.Message;
import com.tuan.chatapp.model.User;
import com.tuan.chatapp.repository.MessageRepository;
import com.tuan.chatapp.repository.UserRepository;
import com.tuan.chatapp.service.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
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

    @Override
    @Transactional
    public MessageResponse saveMessage(MessageRequest messageRequest) {
        Message message = messageMapper.toEntity(messageRequest);
        message.setCreatedAt(LocalDateTime.now());
        Message savedMessage = messageRepository.save(message);
        return messageMapper.toResponse(savedMessage);
    }

    @Override
    public List<MessageResponse> getMessagesByRoom(Long roomId) {
        return messageRepository.findByRoomIdOrderByCreatedAtAsc(roomId).stream()
                .map(m -> {
                    User sender = userRepository.findById(m.getSenderId()).orElse(null);
                    return MessageResponse.builder()
                            .id(m.getId())
                            .senderId(m.getSenderId())
                            .senderUsername(sender != null ? sender.getFullName() : "Unknown")
                            .roomId(m.getRoomId())
                            .content(m.getContent())
                            .createdAt(m.getCreatedAt())
                            .build();
                }).toList();
    }
}

