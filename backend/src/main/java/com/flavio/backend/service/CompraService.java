package com.flavio.backend.service;

import com.flavio.backend.model.Compra;
import com.flavio.backend.model.CompraItem;
import com.flavio.backend.model.Producto;
import com.flavio.backend.model.User;
import com.flavio.backend.repository.CompraRepository;
import com.flavio.backend.repository.ProductoRepository;
import com.flavio.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class CompraService {

    private final CompraRepository compraRepository;
    private final UserRepository userRepository;
    private final ProductoRepository productoRepository;

    public CompraService(CompraRepository compraRepository,
                         UserRepository userRepository,
                         ProductoRepository productoRepository) {
        this.compraRepository = compraRepository;
        this.userRepository = userRepository;
        this.productoRepository = productoRepository;
    }

    public Compra crearCompraDesdeCarrito(Long UserId, List<Map<String, Object>> items) {
        User User = userRepository.findById(UserId)
                .orElseThrow(() -> new RuntimeException("User no encontrado"));

        Compra compra = new Compra();
        compra.setUser(User);
        compra.setFecha(LocalDateTime.now());

        List<CompraItem> compraItems = new ArrayList<>();
        for (Map<String, Object> item : items) {
            Long productoId = Long.valueOf(item.get("productoId").toString());
            Producto producto = productoRepository.findById(productoId)
                    .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

            int cantidad = Integer.parseInt(item.get("cantidad").toString());
            double precioUnitario = Double.parseDouble(item.get("precioUnitario").toString());

            CompraItem ci = new CompraItem();
            ci.setProducto(producto);
            ci.setCantidad(cantidad);
            ci.setPrecio(precioUnitario);
            ci.setCompra(compra);

            compraItems.add(ci);
        }

        compra.setItems(compraItems);
        return compraRepository.save(compra);
    }

    // Método opcional para obtener todas las compras de un User
    public List<Compra> obtenerComprasPorUser(Long UserId) {
        return compraRepository.findByUserId(UserId);
    }
}
