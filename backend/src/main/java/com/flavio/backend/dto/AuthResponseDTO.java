// DTO de respuesta del login
package com.flavio.backend.dto;
import lombok.Data;

@Data
public class AuthResponseDTO {
    private String token;
    private int role; // 1 = ADMIN, 0 = USER

    public AuthResponseDTO(String token, Role role) {
        this.token = token;
        this.role = role == Role.ADMIN ? 1 : 0;
    }
}


enum Role {
    USER,
    ADMIN
}