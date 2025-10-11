import 'package:flutter/material.dart';
import 'package:frontend/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  final String apiSignupUrl;

  const SignupPage({super.key, required this.apiSignupUrl});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    if (passwordController.text.trim() !=
        repeatPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    print('Email enviado: ${nameController.text.trim()}');
    print('Nombre enviado: ${nameController.text.trim()}');
    print('Password enviado: ${passwordController.text.trim()}');

    try {
      final response = await http.post(
        Uri.parse(widget.apiSignupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Suponiendo que devuelve {"token": "..."}
        final userRole = data['role']; // Suponiendo que devuelve {"role": 0}
        final userId = data['id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              token: token,
              userRole: userRole,
              username: nameController.text.trim(),
              email: emailController.text.trim(),
              userId: userId,
            ),
          ),
        );
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Error en registro';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Email inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una contraseña';
                  }
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              TextFormField(
                controller: repeatPasswordController,
                decoration: InputDecoration(labelText: 'Repita su Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una contraseña';
                  }
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              SizedBox(height: 24),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: signup,
                      child: Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
