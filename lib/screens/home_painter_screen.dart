import 'package:flutter/material.dart';
import 'package:painter_connect/screens/project_painter_screen.dart';
import 'package:painter_connect/screens/profile_painter_screen.dart';

class HomePainterScreen extends StatefulWidget {
  const HomePainterScreen({Key? key}) : super(key: key);

  @override
  State<HomePainterScreen> createState() => _HomePainterScreenState();
}

class _HomePainterScreenState extends State<HomePainterScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProjectPainterScreen()),
      );
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
      backgroundColor: const Color(0xFFFFE6D5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 40)),
              const SizedBox(height: 20),
              const Text(
                "Tableau de bord",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text("Gérez vos devis et missions"),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _dashboardBox(
                    "Nouvelles",
                    "12",
                    Colors.orange,
                    Icons.article,
                  ),
                  _dashboardBox(
                    "En cours",
                    "5",
                    Colors.blue,
                    Icons.chat_bubble_outline,
                  ),
                  _dashboardBox("Ce mois", "8", Colors.green, Icons.work),
                  _dashboardBox(
                    "Notes",
                    "4.9",
                    Colors.purple,
                    Icons.star_border,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _infoBox(
                backgroundColor: const Color(0xFFFFF2E2),
                title: "Revenus ce mois",
                content: "4,250 \$\n+15 % vs mois dernier",
                titleColor: Colors.deepOrange,
              ),
              const SizedBox(height: 16),
              _infoBox(
                backgroundColor: const Color(0xFFE6EEFF),
                title: "Taux d’acceptation",
                content: "78%\nVos devis sont acceptés",
                titleColor: Colors.blue[800]!,
              ),
              const SizedBox(height: 16),
              _infoBox(
                backgroundColor: const Color(0xFFE5FFF0),
                title: "Prochaine mission",
                content: "Demain 9h\nPeinture salon - M.Dupont",
                titleColor: Colors.green[700]!,
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

  Widget _dashboardBox(String title, String value, Color color, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required Color backgroundColor,
    required String title,
    required String content,
    required Color titleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
