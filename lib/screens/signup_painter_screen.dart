import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:painter_connect/screens/login_screen.dart';

class SignupPainterScreen extends StatefulWidget {
  const SignupPainterScreen({Key? key}) : super(key: key);

  @override
  State<SignupPainterScreen> createState() => _SignupPainterScreenState();
}

class _SignupPainterScreenState extends State<SignupPainterScreen> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _entrepriseController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _zoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signupPainter() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Création utilisateur Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Ajout des infos supplémentaires dans Firestore
      await FirebaseFirestore.instance
          .collection("painters")
          .doc(credential.user!.uid)
          .set({
            "prenom": _prenomController.text.trim(),
            "nom": _nomController.text.trim(),
            "entreprise": _entrepriseController.text.trim(),
            "email": _emailController.text.trim(),
            "telephone": _telController.text.trim(),
            "zone": _zoneController.text.trim(),
            "experience": _experienceController.text.trim(),
            "description": _descController.text.trim(),
            "createdAt": FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Compte créé avec succès")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/images/logo.png', height: 60),
              const SizedBox(height: 16),
              const Text(
                'Inscription Peintre',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Créez votre compte professionnel pour recevoir des demandes',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _entrepriseController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'entreprise",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _zoneController,
                decoration: const InputDecoration(
                  labelText: 'Zone géographique',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: "Années d'expérience",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description de vos services',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signupPainter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Créer mon compte pro'),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text.rich(
                  TextSpan(
                    text: "Déjà un compte ? ",
                    children: [
                      TextSpan(
                        text: "Se connecter",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
