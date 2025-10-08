import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  String username = "Usuario123";
  String email = "usuario@example.com";
  String password = "";
  bool notificationsEnabled = true;

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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí pondrías la lógica para guardar los datos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cambios guardados")),
                    );
                  }
                },
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
