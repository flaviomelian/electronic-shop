package com.flavio.backend.dto;

public class AuthRequest {
    private String email;
    private String password;
    private String name; // Nuevo campo para el nombre

    // Getters y Setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
