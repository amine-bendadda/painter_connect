import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:painter_connect/screens/home_client_screen.dart';
import 'package:painter_connect/screens/profile_client_screen.dart';
import 'package:dotted_border/dotted_border.dart';

class ProjectClientScreen extends StatefulWidget {
  const ProjectClientScreen({super.key});

  @override
  State<ProjectClientScreen> createState() => _ProjectClientScreenState();
}

class _ProjectClientScreenState extends State<ProjectClientScreen> {
  int _selectedIndex = 0;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _surfaceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = "";

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileClientScreen()),
      );
    }
  }

  void _showReceivedQuotesDialog(String requestId, String requestTitle) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quotes')
        .where('requestId', isEqualTo: requestId)
        .get();

    final quotes = snapshot.docs;

    // 🔥 Récupération des infos des peintres en batch
    final painterIds = quotes.map((q) => q['painterId'] as String).toSet();
    final painterSnapshots = await Future.wait(
      painterIds.map(
        (id) => FirebaseFirestore.instance.collection('painters').doc(id).get(),
      ),
    );

    // Association ID -> nom
    final Map<String, String> painterNames = {};
    for (var snap in painterSnapshots) {
      final data = snap.data();
      painterNames[snap.id] = data?['prenom'] != null && data?['nom'] != null
          ? '${data!['prenom']} ${data['nom']}'
          : 'Peintre inconnu';
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Devis reçus",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cartes de devis
                ...quotes.map((q) {
                  final data = q.data() as Map<String, dynamic>;
                  final duration = data['duration']?.toString() ?? '0';
                  final status = data['status'];
                  final isAccepted = status == 'Accepté';
                  final isRefused = status == 'Refusé';
                  final painterId = data['painterId'];
                  final painterName =
                      painterNames[painterId] ?? 'Peintre inconnu';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du peintre + statut
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              painterName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAccepted
                                    ? Colors.green.withOpacity(0.2)
                                    : isRefused
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status ?? "En attente",
                                style: TextStyle(
                                  color: isAccepted
                                      ? Colors.green
                                      : isRefused
                                      ? Colors.red
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Prix
                        Text(
                          "${data['amount']}€",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(data['description'] ?? ""),
                        const SizedBox(height: 8),
                        // Délai (placeholder fixe)
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 16),
                            const SizedBox(width: 4),
                            Text("$duration jour${duration == '1' ? '' : 's'}"),
                          ],
                        ),

                        // Boutons si en attente
                        if (status == "En attente") ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('quotes')
                                        .doc(q.id)
                                        .update({'status': 'Refusé'});

                                    setState(() {}); // Rebuild popup
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Refuser"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final firestore =
                                        FirebaseFirestore.instance;

                                    // 1. Accepter le devis sélectionné
                                    await firestore
                                        .collection('quotes')
                                        .doc(q.id)
                                        .update({'status': 'Accepté'});

                                    // 2. Refuser tous les autres devis en "En attente" pour la même demande
                                    final otherQuotes = quotes.where(
                                      (quote) => quote.id != q.id,
                                    );
                                    final batch = firestore.batch();

                                    for (final quote in otherQuotes) {
                                      final data =
                                          quote.data() as Map<String, dynamic>;
                                      if (data['status'] == 'En attente') {
                                        batch.update(quote.reference, {
                                          'status': 'Refusé',
                                        });
                                      }
                                    }

                                    // 3. Mettre à jour le statut de la demande
                                    batch.update(
                                      firestore
                                          .collection('requests')
                                          .doc(requestId),
                                      {'status': 'Accepté'},
                                    );

                                    // 4. Appliquer toutes les modifications en une seule opération
                                    await batch.commit();

                                    setState(() {}); // Rebuild popup
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text(
                                    "Accepter",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _publishRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('requests').add({
      'clientId': user.uid,
      'title': _titleController.text.trim(),
      'type': _selectedType,
      'surface': _surfaceController.text.trim(),
      'location': _locationController.text.trim(),
      'date': _dateController.text.trim(),
      'budget': _budgetController.text.trim(),
      'description': _descriptionController.text.trim(),
      'createdAt': Timestamp.now(),
      'status': 'En attente de devis',
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Demande publiée avec succès")),
    );
  }

  Stream<QuerySnapshot> _getUserRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('requests')
        .where('clientId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepté':
        return Colors.green;
      case 'devis reçus':
        return Colors.orange;
      case 'en attente de devis':
      default:
        return Colors.grey;
    }
  }

  void _showNewRequestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Créer une demande de peinture",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Titre du projet",
                      hintText: "Ex: Peinture salon 25m²",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType.isEmpty ? null : _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: "Peinture intérieure",
                        child: Text("Peinture intérieure"),
                      ),
                      DropdownMenuItem(
                        value: "Peinture extérieure",
                        child: Text("Peinture extérieure"),
                      ),
                      DropdownMenuItem(
                        value: "Rénovation",
                        child: Text("Rénovation"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? "";
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Type de peinture",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _surfaceController,
                    decoration: const InputDecoration(
                      labelText: "Surface (m²)",
                      hintText: "Ex: 25",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: "Localisation",
                      hintText: "Ex: Paris 15ème",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Date souhaitée",
                      hintText: "jj/mm/aaaa",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: "Budget estimé",
                      hintText: "Ex: 500-800€",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description détaillée",
                      hintText: "Décrivez votre projet en détail...",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashPattern: [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload_file_outlined, size: 30),
                            SizedBox(height: 8),
                            Text(
                              "Cliquez pour ajouter des photos ou glissez-déposez",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Annuler"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _publishRequest,
                          child: const Text("Publier la demande"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return DropdownButtonFormField<String>(
      items: const [
        DropdownMenuItem(
          value: "Peinture intérieure",
          child: Text("Peinture intérieure"),
        ),
        DropdownMenuItem(
          value: "Peinture extérieure",
          child: Text("Peinture extérieure"),
        ),
        DropdownMenuItem(value: "Rénovation", child: Text("Rénovation")),
      ],
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _requestCard({
    required String requestId,
    required String title,
    required String status,
    required Color statusColor,
    required String count,
    required String location,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$count devis reçus",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Expanded(child: Text(location)),
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showReceivedQuotesDialog(requestId, title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Voir les devis"),
            ),
          ),
        ],
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

  @override
  void dispose() {
    _dateController.dispose();
    _titleController.dispose();
    _surfaceController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 40)),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mes demandes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _showNewRequestDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        "Nouvelles demandes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<User?>(
                future: FirebaseAuth.instance.authStateChanges().first,
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userId = userSnapshot.data!.uid;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .where('clientId', isEqualTo: userId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("Aucune demande trouvée."),
                        );
                      }

                      final requests = snapshot.data!.docs;

                      return Column(
                        children: requests.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          return _requestCard(
                            requestId: doc.id, // <-- indispensable
                            title: data['title']?.toString() ?? '',
                            status: data['status']?.toString() ?? '',
                            statusColor: _getStatusColor(
                              data['status']?.toString() ?? '',
                            ),
                            count:
                                "0", // À remplacer plus tard par le nombre réel de devis
                            location: data['location']?.toString() ?? '',
                            date: data['date']?.toString() ?? '',
                          );
                        }).toList(),
                      );
                    },
                  );
                },
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
                icon: Icons.assignment,
                label: "Project",
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
} // end of class
