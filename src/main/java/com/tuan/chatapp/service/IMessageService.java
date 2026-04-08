package com.tuan.chatapp.service;

import com.tuan.chatapp.dto.request.MessageRequest;
import com.tuan.chatapp.dto.response.MessageResponse;

public interface IMessageService {
    MessageResponse saveMessage(MessageRequest messageRequest);
}
