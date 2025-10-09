import 'package:flutter/material.dart';
import 'package:frontend/pages/main_screen.dart';

class CompraPage extends StatelessWidget {
  final Map<int, int> cart;
  final List<dynamic> products;
  final String token;
  final int userId;
  final String username;

  const CompraPage({
    Key? key,
    required this.cart,
    required this.products,
    required this.token,
    required this.userId,
    required this.username,
  }) : super(key: key);

  void _redirigirHome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          token: token,
          username: username,
          email: '', // Proporciona el email si lo tienes
          userRole: '', // Proporciona el rol si lo tienes
          userId: userId,
          total: 0.0, // Proporciona el total si lo tienes
        ),
      ),
    );
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
              onPressed: () => _redirigirHome(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('PayPal'),
              onPressed: () => _redirigirHome(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.money),
              label: const Text('Pago en Efectivo'),
              onPressed: () => _redirigirHome(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Pago con QR'),
              onPressed: () => _redirigirHome(context),
            ),
          ],
        ),
      ),
    );
  }
}
