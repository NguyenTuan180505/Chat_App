package com.tuan.chatapp.repository;

import com.tuan.chatapp.model.Room;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long> {
    Optional<Room> findByName(String name);
    List<Room> findByType(String type);

    Optional<Room> findByInviteCode(String inviteCode);
}
