import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/compra_page.dart';
import 'package:http/http.dart' as http;

class _CartDialogState extends State<CartDialog> {
  bool isSaving = true;
  String message = "Cargando carrito...";
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserCart(widget.token, widget.userId)
        .then((fetchedCart) {
          setState(() {
            widget.cart.clear();
            widget.cart.addAll(fetchedCart);
            total = _calculateTotal();
          });
        })
        .catchError((error) {
          setState(() {
            isSaving = false;
            message = "Error cargando el carrito: $error";
          });
        })
        .whenComplete(() {
          setState(() {
            isSaving = false;
            message = "Total: \$${total.toStringAsFixed(2)}";
          });
        });
  }

  double _calculateTotal() {
    double totalTemp = 0.0;
    for (var entry in widget.cart.entries) {
      final product = widget.products.firstWhere(
        (p) => p['id'] == entry.key,
        orElse: () => {'precio': 0},
      );
      totalTemp += (product['precio']) * entry.value;
    }
    return totalTemp;
  }

  Future<Map<int, int>> fetchUserCart(String token, int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.6.225:8080/api/carrito/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<int, int> cartMap = {};
      for (var item in data) {
        cartMap[item['productId']] = item['cantidad'];
      }
      return cartMap;
    } else {
      debugPrint('⚠️ Respuesta backend: ${response.body}');
      throw Exception('Error al cargar carrito: ${response.statusCode}');
    }
  }

  Future<void> _updateCartItem(int productId, int newQuantity) async {
    setState(() => isSaving = true);
    final response = await http.post(
      Uri.parse(
        'http://192.168.6.225:8080/api/carrito/${widget.userId}/agregar/$productId?cantidad=$newQuantity',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.cart[productId] = newQuantity;
        total = _calculateTotal();
        isSaving = false;
        message = "Total: \$${total.toStringAsFixed(2)}";
      });
    } else {
      setState(() {
        isSaving = false;
        message = "Error al actualizar producto $productId";
      });
    }
  }

  Future<void> _deleteCartItem(int productId) async {
    setState(() => isSaving = true);
    final response = await http.delete(
      Uri.parse(
        'http://192.168.6.225:8080/api/carrito/${widget.userId}/eliminar/$productId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.cart.remove(productId);
        total = _calculateTotal();
        isSaving = false;
        message = "Producto eliminado ✅ (Total: \$${total.toStringAsFixed(2)})";
      });
    } else {
      setState(() {
        isSaving = false;
        message = "Error al eliminar producto $productId";
      });
    }
  }

  void _showEditDialog(int productId, int currentQuantity) {
    final controller = TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar cantidad"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Nueva cantidad"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(controller.text);
              if (newQty != null && newQty > 0) {
                Navigator.pop(context);
                _updateCartItem(productId, newQty);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("🛒 Carrito de compras"),
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
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ...widget.cart.entries.map((entry) {
                      final product = widget.products.firstWhere(
                        (p) => p['id'] == entry.key,
                        orElse: () => {'nombre': 'Desconocido', 'precio': 0},
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(product['nombre']),
                          subtitle: Text(
                            "Cantidad: ${entry.value} - \$${(product['precio'] * entry.value).toStringAsFixed(2)}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _showEditDialog(entry.key, entry.value),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCartItem(entry.key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompraPage(
                  cart: widget.cart,
                  products: widget.products,
                  token: widget.token,
                  userId: widget.userId,
                  username: widget.username,
                ),
              ),
            );
          },
          child: const Text("Realizar compra"),
        ),
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
  final String username;
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
