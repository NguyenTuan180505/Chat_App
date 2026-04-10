package com.tuan.chatapp.controller;

import com.tuan.chatapp.dto.request.MessageRequest;
import com.tuan.chatapp.dto.response.MessageResponse;
import com.tuan.chatapp.service.IMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class MessageController {
    private final IMessageService  messageService;
    private final SimpMessagingTemplate messagingTemplate;


    @MessageMapping("/chat.group")
    public void sendGroupMessage(MessageRequest messageRequest, Principal principal) {

        String username = principal.getName();

        MessageResponse messageResponse =
                messageService.saveMessage(messageRequest, username);

        messagingTemplate.convertAndSend(
                "/topic/room/" + messageResponse.getRoomId(),
                messageResponse
        );
    }

    @MessageMapping("/chat.private")
    public void sendPrivateMessage(MessageRequest messageRequest, Principal principal){

        String username = principal.getName();

        MessageResponse messageResponse =
                messageService.saveMessage(messageRequest, username);

        messagingTemplate.convertAndSendToUser(
                messageResponse.getReceiverName(),
                "/queue/messages",
                messageResponse
        );
}
}
