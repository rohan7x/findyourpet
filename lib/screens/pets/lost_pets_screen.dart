
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../models/pet.dart';
import '../../widgets/pet_card.dart';

class LostPetsScreen extends StatefulWidget {
  const LostPetsScreen({super.key});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Pet>> _futurePets;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _futurePets = _fetchPets();

    // Simple page fade-in animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<List<Pet>> _fetchPets() async {
    final response = await http.get(Uri.parse('${Config.backendUrl}/pets'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => Pet.fromJson(json))
          .where((pet) => pet.type == 'lost')
          .toList();
    } else {
      throw Exception('Failed to load lost pets');
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Lost Pets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: FutureBuilder<List<Pet>>(
          future: _futurePets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: yellow));
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
                  "No lost pets found",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final pets = snapshot.data!;

            return ListView.builder(
              itemCount: pets.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final pet = pets[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration:
                        Duration(milliseconds: 500 + (index * 100)), // staggered
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    ),
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 5,
                      shadowColor: yellow.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: yellow.withOpacity(0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // Same PetCard widget (functionality not changed)
                        child: PetCard(pet: pet),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yellow,
        onPressed: () {
          // Refresh pets — same logic
          setState(() {
            _futurePets = _fetchPets();
          });
        },
        child: const Icon(Icons.refresh, color: Colors.black),
      ),
    );
  }
}