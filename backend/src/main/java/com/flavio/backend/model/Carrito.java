package com.flavio.backend.model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@Table(name = "carritos")
public class Carrito {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Relación uno a uno con el usuario
    @OneToOne
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    private User usuario;

    // Relación uno a muchos con los items del carrito
    @OneToMany(mappedBy = "carrito", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CarritoItem> items = new ArrayList<>(); // ✅ inicializada

    public Carrito() {}

    public Carrito(User usuario) {
        this.usuario = usuario;
        this.items = new ArrayList<>(); // ✅ inicializada también en constructor
    }
}

