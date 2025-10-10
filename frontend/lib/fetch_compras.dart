import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

Future<List<Compra>> fetchCompras(int usuarioId, String token) async {
  final response = await http.get(
    Uri.parse('http://192.168.6.225:8080/api/compras/$usuarioId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> comprasJson = json.decode(response.body);
    return comprasJson
        .map((json) => Compra.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Error al cargar compras ${response.statusCode}');
  }
}
