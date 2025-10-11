import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final String token;
  final int userId;
  final String initialUsername;
  final String initialEmail;

  const SettingsPage({
    super.key,
    required this.token,
    required this.userId,
    required this.initialUsername,
    required this.initialEmail,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late String username;
  late String email;
  String password = "";
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    username = widget.initialUsername;
    email = widget.initialEmail;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("http://192.168.1.19:8080/api/users/${widget.userId}");

    final body = <String, String>{"name": username, "email": email};
    if (password.isNotEmpty) {
      body["password"] = password;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Cambios guardados")));
        setState(() {
          password = ""; // limpiar campo contraseña
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre de usuario
              TextFormField(
                initialValue: username,
                decoration: const InputDecoration(
                  labelText: "Nombre de usuario",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => username = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un nombre de usuario";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un correo electrónico";
                  }
                  if (!RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  ).hasMatch(value)) {
                    return "Ingresa un correo válido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cambiar contraseña
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nueva contraseña",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return "La contraseña debe tener al menos 6 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notificaciones
              SwitchListTile(
                title: const Text("Recibir notificaciones"),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
