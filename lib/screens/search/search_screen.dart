import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/pet_service.dart';
import '../../widgets/pet_card.dart';
import 'qr_scanner_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petService = Provider.of<PetService>(context, listen: false);
      petService.searchPets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final petService = Provider.of<PetService>(context, listen: false);
    petService.searchPets(
      query: _searchController.text,
      status: _selectedFilter == 'All' ? null : _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pets'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pets by name, breed, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _performSearch();
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedFilter == 'All', (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Lost', _selectedFilter == 'lost', (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Found', _selectedFilter == 'found', (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Dogs', _selectedFilter == 'dog', (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _performSearch();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Cats', _selectedFilter == 'cat', (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  _performSearch();
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Results
          Expanded(
            child: Consumer<PetService>(
              builder: (context, petService, child) {
                if (petService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (petService.filteredPets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pets found',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRScannerScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR Code'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    petService.searchPets();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: petService.filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = petService.filteredPets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PetCard(
                          pet: pet,
                          onTap: () {
                            // Navigate to pet detail
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(String) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? label.toLowerCase() : 'All');
      },
      selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2196F3),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2196F3) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
} 