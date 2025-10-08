package com.flavio.backend.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.Data;

@Data
@Entity
@Table(name = "productos")
public class Producto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    private String descripcion;

    @Column(nullable = false)
    private BigDecimal precio;

    @Column(nullable = false)
    private Integer stock;

    // Nueva columna para la imagen (por ejemplo, URL o nombre del archivo)
    private String imagenUrl;

    public Producto() {}

    public Producto(Long id) {
        this.id = id;
    }
}
