import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/pages/main_screen.dart';
import 'package:http/http.dart' as http;

import 'pages/main_screen.dart'; // asegúrate de usar la ruta correcta
import 'pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electronic Shop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final String apiLoginUrl = "http://192.168.6.225:8080/api/auth/login";
  final String apiSignupUrl = "http://192.168.6.225:8080/api/auth/signup";
  final double total = 0.0;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token =
            data['token']; // suponemos que la API devuelve {"token": "..."}
        final userRole =
            data['role']; // suponemos que la API devuelve {"role": 0}
        final username = data['username'];
        final email = data['email'];
        final userId = data['id'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              token: token,
              userRole: userRole,
              username: username,
              email: email,
              total: total,
              userId: userId,
            ), // <-- pasamos token
          ),
        );
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Error en login';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email con icono de usuario
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Password con icono de candado
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: login,
                        child: const Text("Ingresar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SignupPage(apiSignupUrl: apiSignupUrl),
                            ),
                          );
                        },
                        child: const Text("¿No tienes cuenta? Regístrate"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
