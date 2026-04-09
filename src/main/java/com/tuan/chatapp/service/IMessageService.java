package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.request.MessageRequest;
import com.tuan.chatapp.dto.response.MessageResponse;

import java.util.List;

public interface IMessageService {
    MessageResponse saveMessage(MessageRequest messageRequest);
    List<MessageResponse> getMessagesByRoom(Long roomId);
}
