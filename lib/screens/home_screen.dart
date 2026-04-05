import 'package:flutter/material.dart';
import 'pets/lost_pets_screen.dart';
import 'pets/found_pets_screen.dart';
import 'pets/add_pet_screen.dart';
import 'pets/matches_screen.dart';
import 'profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const LostPetsScreen(),
    const FoundPetsScreen(),
    const MatchesScreen(),
    const AddPetScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Print Firebase token for debugging
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? token = await user.getIdToken();
        print("Firebase ID Token: $token");
      } else {
        print("No user logged in — token unavailable.");
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.black,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Lost Pets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: 'Found Pets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add Pet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
//-------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'pets/lost_pets_screen.dart';
// import 'pets/found_pets_screen.dart';
// import 'pets/add_pet_screen.dart';
// import 'pets/matches_screen.dart';
// import 'profile/profile_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // Print Firebase token for debugging
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         String? token = await user.getIdToken();
//         print("Firebase ID Token: $token");
//       } else {
//         print("No user logged in — token unavailable.");
//       }
//     });
//   }

//   void _navigateTo(Widget page) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => page),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // dark background
//       appBar: AppBar(
//         title: const Text(
//           'Pet Rescue Dashboard',
//           style: TextStyle(
//             color: Colors.amberAccent,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         elevation: 5,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: GridView.count(
//           crossAxisCount: 2, // two columns
//           crossAxisSpacing: 5,
//           mainAxisSpacing: 5,
//           childAspectRatio: 0.5,
//           children: [
//             _buildGridCard(
//               title: 'Lost Pets',
//               icon: Icons.search,
//               color: Colors.orangeAccent,
//               onTap: () => _navigateTo(const LostPetsScreen()),
//             ),
//             _buildGridCard(
//               title: 'Found Pets',
//               icon: Icons.pets,
//               color: Colors.amberAccent,
//               onTap: () => _navigateTo(const FoundPetsScreen()),
//             ),
//             _buildGridCard(
//               title: 'Matches',
//               icon: Icons.check_circle_outline,
//               color: Colors.yellowAccent,
//               onTap: () => _navigateTo(const MatchesScreen()),
//             ),
//             _buildGridCard(
//               title: 'Add Pet',
//               icon: Icons.add_circle_outline,
//               color: Colors.deepOrangeAccent,
//               onTap: () => _navigateTo(const AddPetScreen()),
//             ),
//             _buildGridCard(
//               title: 'Profile',
//               icon: Icons.person_outline,
//               color: Colors.amber,
//               onTap: () => _navigateTo(const ProfileScreen()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGridCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E1E1E),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//           border: Border.all(color: color.withOpacity(0.4), width: 1.2),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 50),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }