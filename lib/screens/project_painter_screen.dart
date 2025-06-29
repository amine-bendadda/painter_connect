import 'package:flutter/material.dart';
import 'package:painter_connect/screens/profile_painter_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectPainterScreen extends StatefulWidget {
  const ProjectPainterScreen({Key? key}) : super(key: key);

  @override
  State<ProjectPainterScreen> createState() => _ProjectPainterScreenState();
}

class _ProjectPainterScreenState extends State<ProjectPainterScreen> {
  int _selectedIndex = 0;

  Stream<QuerySnapshot> _getPendingRequests() {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('status', whereIn: ['En attente de devis', 'devis reçus'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _showRequestDetailsDialog(Map<String, dynamic> data) async {
    final clientId = data['clientId'];

    // Vérification
    if (clientId == null || clientId.toString().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Client ID manquant.")));
      return;
    }

    String clientName = "Client inconnu";
    String clientPhone = "Non renseigné";

    try {
      final clientSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .doc(clientId)
          .get();

      final clientData = clientSnapshot.data();
      if (clientData != null) {
        clientName =
            "${clientData['firstName'] ?? ''} ${clientData['lastName'] ?? ''}"
                .trim();
        clientPhone = clientData['phone'] ?? "Non renseigné";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la récupération du client."),
        ),
      );
      return;
    }

    // Affichage du dialogue
    showDialog(
      context: context,
      builder: (context) {
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Détails de la demande",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Titre et budget
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${data['title'] ?? ''} ${data['surface']}m²",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['type'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${data['budget']}€",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations client
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informations client",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Nom: $clientName"),
                        Text("Téléphone: $clientPhone"),
                        Text("Adresse: ${data['location'] ?? ''}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Détails projet
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Surface"),
                            Text(
                              "${data['surface']} m²",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date souhaitée"),
                            Text(
                              data['date'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Budget
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("€ Budget"),
                      Text(
                        "${data['budget']} €",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(data['description'] ?? "Aucune description"),
                  ),
                  const SizedBox(height: 16),

                  // Photo
                  const Text(
                    "Photos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Aucune photo fournie",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Fermer"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showQuoteDialog(
                              data,
                              data['id'] ?? '',
                              FirebaseAuth.instance.currentUser!.uid,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text("Faire un devis"),
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

  Stream<QuerySnapshot> _getMyQuotes() {
    final currentPainterId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('quotes')
        .where('painterId', isEqualTo: currentPainterId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _showQuoteDialog(
    Map<String, dynamic> data,
    String requestId,
    String painterId,
  ) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController materialController = TextEditingController();
    final TextEditingController laborController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Créer un devis",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade100, Colors.orange.shade50],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['title']} ${data['surface']}m²",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("Client: ${data['clientName'] ?? 'Client'}"),
                        Text("Surface: ${data['surface']}m²"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount & Duration
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Montant total (€)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Durée (jours)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Start date
                  TextField(
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Date de début souhaitée",
                      hintText: "jj/mm/aaaa",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Materials & Labor
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: materialController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Matériaux (€)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: laborController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Main d'œuvre (€)",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description détaillée",
                      hintText: "Décrivez les travaux, matériaux utilisés...",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
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
                          onPressed: () async {
                            final quoteData = {
                              'amount': amountController.text,
                              'duration': durationController.text,
                              'startDate': selectedDate?.toIso8601String(),
                              'materialCost': materialController.text,
                              'laborCost': laborController.text,
                              'description': descriptionController.text,
                              'status': 'En attente',
                              'painterId': painterId,
                              'requestId': requestId,
                              'createdAt': Timestamp.now(),
                            };

                            try {
                              // Enregistrer le devis
                              await FirebaseFirestore.instance
                                  .collection('quotes')
                                  .add(quoteData);

                              // Mettre à jour le statut de la demande
                              await FirebaseFirestore.instance
                                  .collection('requests')
                                  .doc(requestId)
                                  .update({'status': 'devis reçus'});

                              // Fermer le popup
                              Navigator.of(context, rootNavigator: true).pop();

                              // Afficher confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Devis envoyé avec succès"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Erreur lors de l'envoi du devis.",
                                  ),
                                ),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text("Envoyer le devis"),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pop(context); // retour à HomePainterScreen
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePainterScreen()),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 40)),
              const SizedBox(height: 20),
              const Text(
                "Nouvelles demandes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: _getPendingRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Aucune demande disponible."),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  final currentPainterId =
                      FirebaseAuth.instance.currentUser?.uid;

                  return Column(
                    children: docs.map((doc) {
                      final requestId = doc.id;
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = requestId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _requestCard(
                          title: data['title']?.toString() ?? '',
                          client: 'Client',
                          location: data['location']?.toString() ?? '',
                          date: data['date']?.toString() ?? '',
                          priceRange: data['budget']?.toString() ?? '',
                          surface: data['surface']?.toString() ?? '',
                          fullData: data,
                          requestId: requestId,
                          painterId: currentPainterId ?? '',
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                "Mes devis",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: _getMyQuotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("Aucun devis créé.");
                  }

                  final quotes = snapshot.data!.docs;

                  return Column(
                    children: quotes.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final requestId = data['requestId'];

                      if (requestId == null || requestId.toString().isEmpty) {
                        return const SizedBox(); // Ignore le devis invalide
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('requests')
                            .doc(requestId)
                            .get(),

                        builder: (context, requestSnapshot) {
                          if (!requestSnapshot.hasData) {
                            return const SizedBox(); // ou loading
                          }

                          final requestData =
                              requestSnapshot.data!.data()
                                  as Map<String, dynamic>;
                          final clientId = requestData['clientId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('clients')
                                .doc(clientId)
                                .get(),
                            builder: (context, clientSnapshot) {
                              final clientName =
                                  (clientSnapshot.hasData &&
                                      clientSnapshot.data != null)
                                  ? "${clientSnapshot.data!['firstName']} ${clientSnapshot.data!['lastName']}"
                                  : "Client";

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _quoteCard(
                                  quoteId: doc.id,
                                  title: requestData['title'] ?? '',
                                  client: clientName,
                                  location: requestData['location'] ?? '',
                                  date:
                                      data['startDate']?.toString().substring(
                                        0,
                                        10,
                                      ) ??
                                      '',
                                  amount: "${data['amount']}€",
                                  status: data['status'] ?? '',
                                  statusColor: (data['status'] == 'Accepté')
                                      ? Colors.green
                                      : (data['status'] == 'Refusé')
                                      ? Colors.red
                                      : Colors.grey,
                                  onDetailsPressed: () =>
                                      _showRequestDetailsDialog({
                                        'title': requestData['title'] ?? '',
                                        'location':
                                            requestData['location'] ?? '',
                                        'date': requestData['date'] ?? '',
                                        'budget': data['amount'] ?? '',
                                        'surface': requestData['surface'] ?? '',
                                        'description':
                                            requestData['description'] ?? '',
                                        'clientId': clientId,
                                      }),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
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
                icon: Icons.work_outline,
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

  Widget _requestCard({
    required String title,
    required String client,
    required String location,
    required String date,
    required String priceRange,
    required String surface,
    required Map<String, dynamic> fullData,
    required String requestId,
    required String painterId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("$surface (m²)", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Text(location),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                " $priceRange \$",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(date),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () =>
                      _showQuoteDialog(fullData, requestId, painterId),
                  child: const Text("Faire un devis"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRequestDetailsDialog(fullData),
                  child: const Text("Détails"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quoteCard({
    required String quoteId,
    required String title,
    required String client,
    required String location,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required VoidCallback onDetailsPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: TextStyle(color: statusColor)),
              ),
            ],
          ),
          Text(
            "Client: $client",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Text(location),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16),
              const SizedBox(width: 4),
              Text(amount),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(date),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                if (status == "En attente") ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                              "Voulez-vous vraiment annuler ce devis ?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Non"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Oui"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('quotes')
                                .doc(quoteId)
                                .update({'status': 'Refusé'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Devis annulé.")),
                            );
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Erreur lors de l'annulation."),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetailsPressed,
                    child: const Text("Détails"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
