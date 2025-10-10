package com.flavio.backend.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.flavio.backend.service.UserService;
import com.flavio.backend.model.User;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService; // servicio que maneja usuarios

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable Long id,
            @RequestBody Map<String, String> updates) {
        try {
            User updatedUser = userService.updateUser(id, updates);
            return ResponseEntity.ok(Map.of(
                    "id", updatedUser.getId(),
                    "name", updatedUser.getName(),
                    "email", updatedUser.getEmail(),
                    "role", updatedUser.getRole()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}

