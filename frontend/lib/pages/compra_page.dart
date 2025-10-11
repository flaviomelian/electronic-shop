import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/main_screen.dart';
import 'package:http/http.dart' as http;

class CompraPage extends StatelessWidget {
  final Map<int, int> cart;
  final List<dynamic> products;
  final String token;
  final int userId;
  final String username;

  const CompraPage({
    super.key,
    required this.cart,
    required this.products,
    required this.token,
    required this.userId,
    required this.username,
  });

  // Función para enviar la compra al backend
  Future<bool> _guardarCompra(String metodoPago) async {
    List<Map<String, dynamic>> items = cart.entries.map((entry) {
      final product = products.firstWhere(
        (p) => p['id'] == entry.key,
        orElse: () => {'id': entry.key, 'precio': 0},
      );
      return {
        'productoId': entry.key,
        'cantidad': entry.value,
        'precioUnitario': product['precio'],
      };
    }).toList();

    final response = await http.post(
      Uri.parse('http://192.168.1.19:8080/api/compras/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'metodoPago': metodoPago, // opcional, para registrar el método
      }),
    );

    return response.statusCode == 201;
  }

  void _realizarCompra(BuildContext context, String metodoPago) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    bool exito = await _guardarCompra(metodoPago);

    Navigator.pop(context); // cerramos loading

    if (exito) {
      cart.clear(); // vaciamos el carrito local
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(
            token: token,
            username: username,
            email: '',
            userRole: '',
            userId: userId,
            total: 0.0,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al realizar la compra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Efectuar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona un método de pago:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.credit_card),
              label: const Text('Tarjeta de Crédito'),
              onPressed: () => _realizarCompra(context, 'TARJETA'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('PayPal'),
              onPressed: () => _realizarCompra(context, 'PAYPAL'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.money),
              label: const Text('Pago en Efectivo'),
              onPressed: () => _realizarCompra(context, 'EFECTIVO'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Pago con QR'),
              onPressed: () => _realizarCompra(context, 'QR'),
            ),
          ],
        ),
      ),
    );
  }
}
