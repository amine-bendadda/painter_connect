import 'package:flutter/material.dart';
import 'package:painter_connect/screens/project_painter_screen.dart';
import 'package:painter_connect/screens/home_painter_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:painter_connect/screens/login_screen.dart';

class ProfilePainterScreen extends StatefulWidget {
  const ProfilePainterScreen({Key? key}) : super(key: key);

  @override
  State<ProfilePainterScreen> createState() => _ProfilePainterScreenState();
}

class _ProfilePainterScreenState extends State<ProfilePainterScreen> {
  int _selectedIndex = 2;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? painterData;

  @override
  void initState() {
    super.initState();
    fetchPainterData();
  }

  Future<void> fetchPainterData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('painters')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          painterData = doc.data();
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProjectPainterScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePainterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 40)),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFFE6D5),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 6),
                    Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Prénom",
                      painterData?["prenom"] ?? "",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField("Nom", painterData?["nom"] ?? ""),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField("Email", _auth.currentUser?.email ?? ""),
              const SizedBox(height: 12),
              _buildTextField("Téléphone", painterData?["telephone"] ?? ""),
              const SizedBox(height: 12),
              _buildTextField("Zone géographique", painterData?["zone"] ?? ""),
              const SizedBox(height: 12),
              _buildTextField(
                "Description de vos services",
                painterData?["description"] ?? "",
              ),
              const SizedBox(height: 12),
              _buildTextField("Olde Mot de passe", "", isPassword: true),
              const SizedBox(height: 12),
              _buildTextField("new le mot de passe", "", isPassword: true),
              const SizedBox(height: 12),
              _buildTextField(
                "Confirmer le mot de passe",
                "",
                isPassword: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => _onItemTapped(1),
        child: const Icon(Icons.home, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.work_outline,
                label: "Home",
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              const SizedBox(width: 40),
              _buildNavItem(
                icon: Icons.person,
                label: "Profile",
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      obscureText: isPassword,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.orange : Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.orange : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
