// // // lib/screens/pets/found_pets_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../config.dart';
// import '../../models/pet.dart';
// import '../../widgets/pet_card.dart';

// class FoundPetsScreen extends StatefulWidget {
//   const FoundPetsScreen({super.key});

//   @override
//   State<FoundPetsScreen> createState() => _FoundPetsScreenState();
// }

// class _FoundPetsScreenState extends State<FoundPetsScreen> {
//   late Future<List<Pet>> _futurePets;

//   @override
//   void initState() {
//     super.initState();
//     _futurePets = _fetchPets();
//   }

//   Future<List<Pet>> _fetchPets() async {
//     final response = await http.get(Uri.parse('${Config.backendUrl}/pets'));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data
//           .map((json) => Pet.fromJson(json))
//           .where((pet) => pet.type == 'found') // only show found pets
//           .toList();
//     } else {
//       throw Exception('Failed to load found pets');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Found Pets"),
//       ),
//       body: FutureBuilder<List<Pet>>(
//         future: _futurePets,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No found pets reported"));
//           }

//           final pets = snapshot.data!;
//           return ListView.builder(
//             itemCount: pets.length,
//             itemBuilder: (context, index) {
//               return PetCard(pet: pets[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
//  }
 
 //-----------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../models/pet.dart';
import '../../widgets/pet_card.dart';

class FoundPetsScreen extends StatefulWidget {
  const FoundPetsScreen({super.key});

  @override
  State<FoundPetsScreen> createState() => _FoundPetsScreenState();
}

class _FoundPetsScreenState extends State<FoundPetsScreen> {
  late Future<List<Pet>> _futurePets;

  @override
  void initState() {
    super.initState();
    _futurePets = _fetchPets();
  }

  Future<List<Pet>> _fetchPets() async {
    final response = await http.get(Uri.parse('${Config.backendUrl}/pets'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Pet.fromJson(json))
          .where((pet) => pet.type == 'found') // only show found pets
          .toList();
    } else {
      throw Exception('Failed to load found pets');
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      // Gradient black background like your image
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000), // pure black
              Color(0xFF0A0A0A), // slightly lighter black
              Color(0xFF1A1A1A), // dark greyish black at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "Found Pets",
                  style: TextStyle(
                    color: yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Pet>>(
                  future: _futurePets,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: yellow),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No found pets reported",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    final pets = snapshot.data!;
                    return ListView.builder(
                      itemCount: pets.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C), // dark card
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: yellow.withOpacity(0.4), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: yellow.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PetCard(pet: pet),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}