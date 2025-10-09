package com.flavio.backend.repository;

import com.flavio.backend.model.Compra;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CompraRepository extends JpaRepository<Compra, Long> {
    List<Compra> findByUserId(Long usuarioId);
}
