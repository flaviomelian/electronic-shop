import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/cart_dialog.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String username;
  final String email;
  final int userId;
  final String userRole; // "ADMIN" o "USER"

  const HomePage({
    super.key,
    required this.token,
    required this.username,
    required this.email,
    required this.userRole,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = "http://192.168.1.19:8080/api/productos"; // tu backend
  List<dynamic> products = [];
  bool isLoading = true;
  Map<int, int> cart = {};
  late final String token;
  late final bool isAdmin;
  late final int userId;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    isAdmin = widget.userRole == "ADMIN";
    userId = widget.userId;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        setState(() {
          products = decoded.map((p) {
            p['id'] = int.parse(p['id'].toString());
            return p;
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar productos: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  void addToCart(dynamic productId) async {
    final int id = int.parse(productId.toString());

    // 🔹 Actualiza localmente primero (respuesta rápida en la UI)
    setState(() {
      cart[id] = (cart[id] ?? 0) + 1;
    });

    // 🔹 Luego sincroniza con el backend
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.1.19:8080/api/carrito/$userId/agregar/$id?cantidad=${cart[id]}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Producto $id agregado/actualizado en el backend');
      } else {
        debugPrint(
          '⚠️ Error al agregar producto $id: ${response.statusCode} -> ${response.body}',
        );
        // Si falla, revertimos el cambio local
        setState(() {
          cart[id] = (cart[id]! > 1) ? cart[id]! - 1 : 0;
          if (cart[id] == 0) cart.remove(id);
        });
      }
    } catch (e) {
      debugPrint('❌ Error de red al agregar producto $id: $e');
      // Revertimos también en caso de excepción
      setState(() {
        cart[id] = (cart[id]! > 1) ? cart[id]! - 1 : 0;
        if (cart[id] == 0) cart.remove(id);
      });
    }
  }

  Future<void> deleteProduct(dynamic productId) async {
    final int id = int.parse(productId.toString());
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((p) => p['id'] == id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Producto eliminado")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error eliminando producto: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );
      if (response.statusCode == 201) {
        await fetchProducts(); // recargar productos
        Navigator.pop(context); // cerrar el dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto creado correctamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creando producto: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );
      if (response.statusCode == 200) {
        await fetchProducts();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto actualizado correctamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error actualizando producto: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  double get total {
    double sum = 0;
    for (var entry in cart.entries) {
      final product = products.firstWhere(
        (p) => p['id'] == entry.key,
        orElse: () => {'precio': 0},
      );
      sum += (product['precio'] ?? 0) * entry.value;
    }
    return sum;
  }

  void showCreateProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();
    final imagenUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Producto"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Ingrese un nombre"
                      : null,
                ),
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: "Precio"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || double.tryParse(value) == null
                      ? "Ingrese un precio válido"
                      : null,
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: "Stock"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                      ? "Ingrese un stock válido"
                      : null,
                ),
                TextFormField(
                  controller: imagenUrlController,
                  decoration: const InputDecoration(labelText: "URL Imagen"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                createProduct({
                  "nombre": nombreController.text,
                  "descripcion": descripcionController.text,
                  "precio": double.parse(precioController.text),
                  "stock": int.parse(stockController.text),
                  "imagenUrl": imagenUrlController.text,
                });
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  void showEditProductDialog(Map<String, dynamic> product) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: product['nombre']);
    final descripcionController = TextEditingController(
      text: product['descripcion'],
    );
    final precioController = TextEditingController(
      text: product['precio'].toString(),
    );
    final stockController = TextEditingController(
      text: product['stock'].toString(),
    );
    final imagenUrlController = TextEditingController(
      text: product['imagenUrl'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Producto"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Ingrese un nombre"
                      : null,
                ),
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: "Precio"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || double.tryParse(value) == null
                      ? "Ingrese un precio válido"
                      : null,
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: "Stock"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                      ? "Ingrese un stock válido"
                      : null,
                ),
                TextFormField(
                  controller: imagenUrlController,
                  decoration: const InputDecoration(labelText: "URL Imagen"),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                updateProduct(product['id'], {
                  "nombre": nombreController.text,
                  "descripcion": descripcionController.text,
                  "precio": double.parse(precioController.text),
                  "stock": int.parse(stockController.text),
                  "imagenUrl": imagenUrlController.text,
                });
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Electronic Shop"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
            ? const Center(child: Text("No hay productos disponibles"))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 90.0,
                  ), // espacio suficiente para los FABs
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final imageUrl = product['imagenUrl'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['descripcion'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "\$${product['precio']} - Stock: ${product['stock']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          addToCart(product['id']);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${product['nombre']} añadido al carrito",
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        },
                                        child: const Text("Comprar"),
                                      ),
                                      if (isAdmin) ...[
                                        const SizedBox(width: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  deleteProduct(product['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      225,
                                                      136,
                                                      130,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              child: const Text("Eliminar"),
                                            ),
                                            const SizedBox(width: 4),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  showEditProductDialog(
                                                    product,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      136,
                                                      202,
                                                      255,
                                                    ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              child: const Text("Editar"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

        floatingActionButton: Material(
          type: MaterialType.transparency, // <-- esto es lo importante
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: FloatingActionButton.extended(
                  heroTag: "cart_button",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CartDialog(
                        cart: cart,
                        products: products,
                        token: token,
                        username: widget.username,
                        userId: widget.userId,
                      ),
                    );
                  },
                  label: Text("Carrito"),
                  icon: const Icon(Icons.shopping_cart),
                  elevation: 0,
                ),
              ),
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: FloatingActionButton(
                    onPressed: showCreateProductDialog,
                    elevation: 0,
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
