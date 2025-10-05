package com.flavio.backend.controller;

import com.flavio.backend.dto.AuthRequest;
import com.flavio.backend.dto.AuthResponse;
import com.flavio.backend.model.User;
import com.flavio.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        try {
            String token = authService.login(request.getEmail(), request.getPassword());
            return ResponseEntity.ok(new AuthResponse(token));
        } catch (Exception e) {
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }

    @PostMapping("/signup")
    public ResponseEntity<?> register(@RequestBody AuthRequest request) {
        try {
            User user = authService.register(request.getEmail(), request.getName(), request.getPassword());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
