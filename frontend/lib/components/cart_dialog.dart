import 'package:flutter/material.dart';
import 'package:frontend/pages/home.dart';
import 'package:http/http.dart' as http;

class _CartDialogState extends State<CartDialog> {
  bool isSaving = true;
  String message = "Guardando carrito...";

  @override
  void initState() {
    super.initState();
    _saveCartToBackend();
  }

  Future<void> _saveCartToBackend() async {
    try {
      for (var entry in widget.cart.entries) {
        final productId = entry.key;
        final cantidad = entry.value;

        final response = await http.post(
          Uri.parse(
            'http://192.168.6.225:8080/api/carrito/${widget.userId}/agregar/$productId?cantidad=$cantidad',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Error al guardar producto $productId: ${response.statusCode}',
          );
        }
      }

      setState(() {
        isSaving = false;
        message = "Carrito sincronizado con el servidor ✅";
      });
    } catch (e) {
      setState(() {
        isSaving = false;
        message = "Error guardando el carrito: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Carrito de compras"),
      content: SizedBox(
        width: double.maxFinite,
        child: isSaving
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(message),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: widget.cart.entries.map((entry) {
                        final product = widget.products.firstWhere(
                          (p) => p['id'] == entry.key,
                          orElse: () => {'nombre': 'Desconocido', 'precio': 0},
                        );
                        return ListTile(
                          title: Text(product['nombre']),
                          subtitle: Text(
                            "Cantidad: ${entry.value} - \$${(product['precio'] * entry.value).toStringAsFixed(2)}",
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}

class CartDialog extends StatefulWidget {
  final Map<int, int> cart;
  final List<dynamic> products;
  final String token;
  final String username; // o userId si lo tienes disponible
  final int userId;

  const CartDialog({
    super.key,
    required this.cart,
    required this.products,
    required this.token,
    required this.username,
    required this.userId,
  });

  @override
  State<CartDialog> createState() => _CartDialogState();
}
