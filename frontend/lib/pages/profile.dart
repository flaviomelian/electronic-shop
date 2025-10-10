import 'package:flutter/material.dart';
import '../models.dart';
import '../fetch_compras.dart'; // donde está la función fetchCompras

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final double total;
  final int usuarioId;
  final String token;

  const ProfilePage({
    super.key,
    required this.username,
    required this.email,
    required this.total,
    required this.usuarioId,
    required this.token,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<Compra>> _comprasFuture;
  final Set<int> _expandedCompras = {}; // Guarda IDs de compras expandidas

  @override
  void initState() {
    super.initState();
    _comprasFuture = fetchCompras(widget.usuarioId, widget.token);
  }

  void _toggleCompra(int compraId) {
    setState(() {
      if (_expandedCompras.contains(compraId)) {
        _expandedCompras.remove(compraId);
      } else {
        _expandedCompras.add(compraId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://www.example.com/profile-image.jpg',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "Compras:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Compra>>(
                future: _comprasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar compras: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Sin compras.'));
                  }

                  final compras = snapshot.data!;

                  return ListView.builder(
                    itemCount: compras.length,
                    itemBuilder: (context, index) {
                      final compra = compras[index];
                      final isExpanded = _expandedCompras.contains(compra.id);

                      final compraTotal = compra.items.fold<double>(
                        0,
                        (previousValue, item) =>
                            previousValue + item.cantidad * item.precio,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Compra #${compra.id} - \$${compraTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _toggleCompra(compra.id),
                                    child: Text(
                                      isExpanded ? 'Ocultar' : 'Ver detalle',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fecha: ${compra.fecha.toLocal()}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                Table(
                                  border: TableBorder.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(
                                      3,
                                    ), // Nombre del producto
                                    1: FlexColumnWidth(1), // Cantidad
                                    2: FlexColumnWidth(1), // Precio
                                  },
                                  children: [
                                    // Header
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                      ),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text(
                                            'Producto',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text(
                                            'Uds.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text(
                                            'Precio',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Filas de items
                                    ...compra.items.map(
                                      (item) => TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(item.producto.nombre),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(
                                              item.cantidad.toString(),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(
                                              '\$${item.precio.toStringAsFixed(2)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
