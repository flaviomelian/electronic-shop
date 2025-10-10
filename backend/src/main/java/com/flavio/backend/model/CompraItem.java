package com.flavio.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "compra_items")
public class CompraItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int cantidad;
    private double precio; // precio al momento de la compra

    @ManyToOne
    @JoinColumn(name = "producto_id")
    private Producto producto;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "compra_id")
    private Compra compra;
}
