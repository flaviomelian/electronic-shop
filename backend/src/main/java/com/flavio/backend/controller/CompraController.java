package com.flavio.backend.controller;

import com.flavio.backend.model.Compra;
import com.flavio.backend.model.User;
import com.flavio.backend.repository.UserRepository;
import com.flavio.backend.service.CompraService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/compras")
public class CompraController {

    private final CompraService compraService;
    private final UserRepository userRepository;

    public CompraController(CompraService compraService, UserRepository userRepository) {
        this.compraService = compraService;
        this.userRepository = userRepository;
    }

    @PostMapping("/{usuarioId}")
    public ResponseEntity<?> crearCompra(
            @PathVariable Long usuarioId,
            @RequestBody Map<String, Object> payload) {

        List<Map<String, Object>> items = (List<Map<String, Object>>) payload.get("items");
        Compra compra = compraService.crearCompraDesdeCarrito(usuarioId, items);

        return ResponseEntity.status(HttpStatus.CREATED).body(compra);
    }

    @GetMapping("/{usuarioId}")
    public ResponseEntity<List<Compra>> listarCompras(@PathVariable Long usuarioId) {
        User usuario = userRepository.findById(usuarioId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        List<Compra> compras = compraService.obtenerComprasPorUser(usuarioId);
        return ResponseEntity.ok(compras);
    }
}
