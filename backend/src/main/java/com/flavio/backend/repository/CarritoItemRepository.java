package com.flavio.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.flavio.backend.model.CarritoItem;

public interface CarritoItemRepository extends JpaRepository<CarritoItem, Long> { }
