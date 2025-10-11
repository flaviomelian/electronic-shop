import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchName(int usuarioId, String token) async {
  final url = Uri.parse('http://192.168.1.19:8080/api/users/$usuarioId');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['name'] ?? 'Usuario';
  } else {
    throw Exception('Error al obtener el nombre: ${response.statusCode}');
  }
}