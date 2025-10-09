package com.flavio.backend.controller;

import com.flavio.backend.model.Carrito;
import com.flavio.backend.model.CarritoItem;
import com.flavio.backend.model.Producto;
import com.flavio.backend.repository.CarritoRepository;
import com.flavio.backend.repository.ProductoRepository;
import com.flavio.backend.service.CarritoService;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/carrito")
public class CarritoController {

    private final CarritoService carritoService;
    private final ProductoRepository productoRepository;
    private final CarritoRepository carritoRepository;

    public CarritoController(CarritoService carritoService, ProductoRepository productoRepository,
            CarritoRepository carritoRepository) {
        this.carritoService = carritoService;
        this.productoRepository = productoRepository;
        this.carritoRepository = carritoRepository;
    }

    @GetMapping("/{usuarioId}")
    public ResponseEntity<?> obtenerCarrito(@PathVariable Long usuarioId) {
        Carrito carrito = carritoService.obtenerCarrito(usuarioId);

        // Mapea los items a un formato más simple para Flutter
        List<Map<String, Object>> items = carrito.getItems().stream()
                .map(item -> Map.of(
                        "productId", (Object) item.getProducto().getId(),
                        "cantidad", (Object) item.getCantidad()))
                .toList();

        return ResponseEntity.ok(items);
    }

    @PostMapping("/{usuarioId}/agregar/{productoId}")
    public ResponseEntity<?> agregarProducto(
            @PathVariable Long usuarioId,
            @PathVariable Long productoId,
            @RequestParam int cantidad) {

        Carrito carrito = carritoService.obtenerCarrito(usuarioId);

        Producto producto = productoRepository.findById(productoId)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        // Verifica si el producto ya está en el carrito
        Optional<CarritoItem> existente = carrito.getItems().stream()
                .filter(i -> i.getProducto().getId().equals(productoId))
                .findFirst();

        if (existente.isPresent()) {
            CarritoItem item = existente.get();
            item.setCantidad(item.getCantidad() + cantidad); // suma la cantidad
        } else {
            CarritoItem item = new CarritoItem();
            item.setProducto(producto);
            item.setCantidad(cantidad);
            item.setCarrito(carrito);
            carrito.getItems().add(item);
        }

        carritoRepository.save(carrito);
        return ResponseEntity.ok(carrito);
    }

    @DeleteMapping("/{usuarioId}/eliminar/{productoId}")
    public ResponseEntity<?> eliminarProducto(@PathVariable Long usuarioId, @PathVariable Long productoId) {
        Carrito carrito = carritoService.obtenerCarrito(usuarioId);

        boolean eliminado = carrito.getItems().removeIf(
                item -> item.getProducto().getId().equals(productoId));

        if (!eliminado) return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("El producto no está en el carrito");

        carritoRepository.save(carrito);
        return ResponseEntity.ok(carrito);
    }

}
