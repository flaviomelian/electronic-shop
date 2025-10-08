package com.flavio.backend.controller;

import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.flavio.backend.model.Carrito;
import com.flavio.backend.model.CarritoItem;
import com.flavio.backend.model.Producto;
import com.flavio.backend.service.ProductoService;
import com.flavio.backend.service.CarritoService;
import com.flavio.backend.repository.ProductoRepository;
import com.flavio.backend.repository.CarritoRepository;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ProductoController {

    private final ProductoService productoService;
    private final CarritoService carritoService;
    private final ProductoRepository productoRepository;
    private final CarritoRepository carritoRepository;

    public ProductoController(ProductoService productoService,
                              CarritoService carritoService,
                              ProductoRepository productoRepository,
                              CarritoRepository carritoRepository) {
        this.productoService = productoService;
        this.carritoService = carritoService;
        this.productoRepository = productoRepository;
        this.carritoRepository = carritoRepository;
    }

    // ===================== PRODUCTOS =====================
    @GetMapping("/productos")
    public ResponseEntity<?> listar() {
        return ResponseEntity.ok(productoService.listarProductos());
    }

    @GetMapping("/productos/{id}")
    public ResponseEntity<?> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(productoService.obtenerProductoPorId(id));
    }

    @PostMapping("/productos")
    public ResponseEntity<?> crear(@RequestBody Producto producto) {
        return ResponseEntity.ok(productoService.guardarProducto(producto));
    }

    @PutMapping("/productos/{id}")
    public ResponseEntity<?> actualizar(@PathVariable Long id, @RequestBody Producto producto) {
        return ResponseEntity.ok(productoService.actualizarProducto(id, producto));
    }

    @DeleteMapping("/productos/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        productoService.eliminarProducto(id);
        return ResponseEntity.ok().build();
    }

}
