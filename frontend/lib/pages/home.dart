import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = "http://192.168.1.17:8080/api/productos";
  List<dynamic> products = [];
  bool isLoading = true;
  Map<int, int> cart = {};
  late final String token;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // <-- importante para evitar 403
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "No autorizado: verifica que el token sea válido.")),
        );
      } else {
        throw Exception(
            "Error al cargar productos ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  void addToCart(int productId) {
    setState(() {
      if (cart.containsKey(productId)) {
        cart[productId] = cart[productId]! + 1;
      } else {
        cart[productId] = 1;
      }
    });
  }

  double get total {
    double sum = 0;
    for (var entry in cart.entries) {
      final product = products.firstWhere(
        (p) => p['id'] == entry.key,
        orElse: () => {'precio': 0},
      );
      sum += product['precio'] * entry.value;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Electronic Shop"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No hay productos disponibles"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.devices, size: 50),
                        title: Text(product['nombre']),
                        subtitle: Text(
                            "\$${product['precio']} - Stock: ${product['stock']}"),
                        trailing: ElevatedButton(
                          child: const Text("Comprar"),
                          onPressed: () {
                            addToCart(product['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "${product['nombre']} añadido al carrito"),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                CartDialog(cart: cart, products: products),
          );
        },
        label: Text("Total: \$${total.toStringAsFixed(2)}"),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartDialog extends StatelessWidget {
  final Map<int, int> cart;
  final List<dynamic> products;

  const CartDialog({super.key, required this.cart, required this.products});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Carrito de compras"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: cart.entries.map((entry) {
            final product = products.firstWhere(
              (p) => p['id'] == entry.key,
              orElse: () => {'nombre': 'Desconocido', 'precio': 0},
            );
            return ListTile(
              title: Text(product['nombre']),
              subtitle: Text(
                  "Cantidad: ${entry.value} - \$${(product['precio'] * entry.value).toStringAsFixed(2)}"),
            );
          }).toList(),
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
