package com.flavio.backend.service;

import com.flavio.backend.model.Carrito;
import com.flavio.backend.model.CarritoItem;
import com.flavio.backend.model.Producto;
import com.flavio.backend.model.User;
import com.flavio.backend.repository.CarritoRepository;
import com.flavio.backend.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

@Service
public class CarritoService {

    private final CarritoRepository carritoRepository;
    private final UserRepository userRepository;

    public CarritoService(CarritoRepository carritoRepository, UserRepository userRepository) {
        this.carritoRepository = carritoRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public Carrito obtenerCarrito(Long usuarioId) {
        return carritoRepository.findByUsuarioIdWithItems(usuarioId)
                .orElseGet(() -> {
                    User user = userRepository.findById(usuarioId).orElseThrow();
                    Carrito carrito = new Carrito(user);
                    return carritoRepository.save(carrito);
                });
    }

    @Transactional
    public Carrito agregarProducto(Long usuarioId, Long productoId, int cantidad) {
        Carrito carrito = obtenerCarrito(usuarioId);

        var existingItem = carrito.getItems().stream()
                .filter(item -> item.getProducto().getId().equals(productoId))
                .findFirst();

        if (existingItem.isPresent()) {
            existingItem.get().setCantidad(existingItem.get().getCantidad() + cantidad);
        } else {
            CarritoItem item = new CarritoItem();
            item.setProducto(new Producto(productoId)); // Solo con id
            item.setCantidad(cantidad);
            item.setCarrito(carrito);
            carrito.getItems().add(item);
        }

        return carritoRepository.save(carrito);
    }
}
