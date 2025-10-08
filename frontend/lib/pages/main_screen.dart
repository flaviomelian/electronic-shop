import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'settings.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final String username;
  final String email;
  final String userRole;
  final double total;
  final int userId;

  const MainScreen({
    super.key,
    required this.token,
    required this.username,
    required this.email,
    required this.userRole,
    required this.total,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        token: widget.token,
        username: widget.username,
        email: widget.email,
        userRole: widget.userRole,
        userId: widget.userId,
      ),
      ProfilePage(
        username: widget.username,
        email: widget.email,
        total: widget.total,
      ),
      const SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
        ],
      ),
    );
  }
}
