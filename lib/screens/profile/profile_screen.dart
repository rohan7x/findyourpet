import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/pet_service.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final petService = Provider.of<PetService>(context, listen: false);

    // Fetch pets once when screen opens
    petService.fetchPets();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.yellowAccent),
      ),
      body: Consumer2<AuthService, PetService>(
        builder: (context, authService, petService, child) {
          final user = authService.currentUser;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellowAccent),
            );
          }

          // Compute dynamic counts from _pets list
          final lostPetsCount = petService.pets
              .where((p) => p.type.toLowerCase() == 'lost')
              .length;
          final foundPetsCount = petService.pets
              .where((p) => p.type.toLowerCase() == 'found')
              .length;
          final reunitedCount = petService.pets
              .where((p) => p.type.toLowerCase() == 'reunited')
              .length;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1A1A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.yellowAccent.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellowAccent.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.yellowAccent,
                            child: Icon(Icons.person, size: 55, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats section (Dynamic)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Lost Pets',
                          lostPetsCount.toString(),
                          Icons.search,
                          Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Found Pets',
                          foundPetsCount.toString(),
                          Icons.pets,
                          Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Reunited',
                          reunitedCount.toString(),
                          Icons.favorite,
                          Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Sign Out
                  CustomButton(
                    text: 'Sign Out',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.yellowAccent)),
                          content: const Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellowAccent,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await authService.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    backgroundColor: Colors.yellowAccent,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellowAccent.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
