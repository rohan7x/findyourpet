import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_track/models/pet.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePetDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPetImage(),
            const SizedBox(height: 20),
            _buildStatusBadge(),
            const SizedBox(height: 20),
            _buildPetInfoCard(context),
            const SizedBox(height: 16),
            _buildOwnerInfoCard(context),
            const SizedBox(height: 16),
            _buildLocationCard(context),
            if (pet.status == 'found') _buildContactButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    return Hero(
      tag: 'pet-image-${pet.id}',
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: pet.photoUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pet.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPetPlaceholder();
                  },
                ),
              )
            : _buildPetPlaceholder(),
      ),
    );
  }

  Widget _buildPetPlaceholder() {
    return Center(
      child: Icon(
        pet.type == 'dog' ? Icons.pets : Icons.pets,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isLost = pet.status == 'lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLost ? Colors.red : Colors.green,
        ),
      ),
      child: Text(
        pet.status.toUpperCase(),
        style: TextStyle(
          color: isLost ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPetInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', pet.name),
            _buildInfoRow('Type', pet.type.toUpperCase()),
            _buildInfoRow('Breed', pet.breed),
            _buildInfoRow('Color', pet.color),
            if (pet.collarColor.isNotEmpty)
              _buildInfoRow('Collar Color', pet.collarColor),
            if (pet.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(pet.description),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', pet.ownerName),
            _buildInfoRow('Phone', pet.ownerPhone),
            _buildInfoRow('Email', pet.ownerEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Address', pet.address),
            _buildInfoRow('Last Seen', _dateFormat.format(pet.lastSeenDate)),
            _buildInfoRow('Posted', _dateFormat.format(pet.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _callOwner,
            icon: const Icon(Icons.phone),
            label: const Text('Call Owner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _messageOwner,
            icon: const Icon(Icons.message),
            label: const Text('Send Message'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callOwner() async {
    final phoneUrl = Uri.parse('tel:${pet.ownerPhone}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }
  }

  Future<void> _messageOwner() async {
    final smsUrl = Uri.parse('sms:${pet.ownerPhone}');
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    }
  }

  Future<void> _sharePetDetails() async {
    // Implement share functionality using share_plus package
    // Example: await Share.share('Check out this ${pet.status} pet: ${pet.name}');
  }
}// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:pet_track/models/pet.dart';

// class PetDetailScreen extends StatelessWidget {
//   final Pet pet;
//   static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

//   const PetDetailScreen({
//     super.key,
//     required this.pet,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(pet.name),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: _sharePetDetails,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildPetImage(),
//             const SizedBox(height: 20),
//             _buildStatusBadge(),
//             const SizedBox(height: 20),
//             _buildPetInfoCard(context),
//             const SizedBox(height: 16),
//             _buildOwnerInfoCard(context),
//             const SizedBox(height: 16),
//             _buildLocationCard(context),
//             if (pet.status == 'found') _buildContactButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPetImage() {
//     return Hero(
//       tag: 'pet-image-${pet.id}',
//       child: Container(
//         height: 200,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.grey[200],
//         ),
//         child: pet.photoUrls.isNotEmpty
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   pet.photoUrls.first,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return _buildPetPlaceholder();
//                   },
//                 ),
//               )
//             : _buildPetPlaceholder(),
//       ),
//     );
//   }

//   Widget _buildPetPlaceholder() {
//     return Center(
//       child: Icon(
//         pet.type == 'dog' ? Icons.pets : Icons.pets,
//         size: 80,
//         color: Colors.grey[400],
//       ),
//     );
//   }

//   Widget _buildStatusBadge() {
//     final isLost = pet.status == 'lost';
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: isLost ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isLost ? Colors.red : Colors.green,
//         ),
//       ),
//       child: Text(
//         pet.status.toUpperCase(),
//         style: TextStyle(
//           color: isLost ? Colors.red : Colors.green,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildPetInfoCard(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Pet Information',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow('Name', pet.name),
//             _buildInfoRow('Type', pet.type.toUpperCase()),
//             _buildInfoRow('Breed', pet.breed),
//             _buildInfoRow('Color', pet.color),
//             if (pet.collarColor.isNotEmpty)
//               _buildInfoRow('Collar Color', pet.collarColor),
//             if (pet.description.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               Text(
//                 'Description',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(pet.description),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOwnerInfoCard(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Owner Information',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow('Name', pet.ownerName),
//             _buildInfoRow('Phone', pet.ownerPhone),
//             _buildInfoRow('Email', pet.ownerEmail),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationCard(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Location Information',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildInfoRow('Address', pet.address),
//             _buildInfoRow('Last Seen', _dateFormat.format(pet.lastSeenDate)),
//             _buildInfoRow('Posted', _dateFormat.format(pet.createdAt)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContactButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: _callOwner,
//             icon: const Icon(Icons.phone),
//             label: const Text('Call Owner'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             onPressed: _messageOwner,
//             icon: const Icon(Icons.message),
//             label: const Text('Send Message'),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _callOwner() async {
//     final phoneUrl = Uri.parse('tel:${pet.ownerPhone}');
//     if (await canLaunchUrl(phoneUrl)) {
//       await launchUrl(phoneUrl);
//     }
//   }

//   Future<void> _messageOwner() async {
//     final smsUrl = Uri.parse('sms:${pet.ownerPhone}');
//     if (await canLaunchUrl(smsUrl)) {
//       await launchUrl(smsUrl);
//     }
//   }

//   Future<void> _sharePetDetails() async {
//     // Implement share functionality using share_plus package
//     // Example: await Share.share('Check out this ${pet.status} pet: ${pet.name}');
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_track/models/pet.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = pet.status == 'lost';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _sharePetDetails,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetImage(),
              const SizedBox(height: 20),
              _buildStatusBadge(isLost),
              const SizedBox(height: 20),
              _buildPetInfoCard(context),
              const SizedBox(height: 16),
              _buildOwnerInfoCard(context),
              const SizedBox(height: 16),
              _buildLocationCard(context),
              if (pet.status == 'found') _buildContactButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    return Hero(
      tag: 'pet-image-${pet.id}',
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: pet.photoUrls.isNotEmpty
              ? Image.network(
                  pet.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPetPlaceholder(),
                )
              : _buildPetPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPetPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          pet.type == 'dog' ? Icons.pets : Icons.pets,
          size: 80,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isLost) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isLost ? Colors.redAccent.withOpacity(0.15) : Colors.greenAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isLost ? Colors.redAccent : Colors.greenAccent,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isLost ? Colors.redAccent : Colors.greenAccent).withOpacity(0.3),
              blurRadius: 6,
            )
          ],
        ),
        child: Text(
          pet.status.toUpperCase(),
          style: TextStyle(
            color: isLost ? Colors.redAccent : Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoCard(BuildContext context) {
    return _frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('🐾 Pet Information'),
          const SizedBox(height: 16),
          _buildInfoRow('Name', pet.name),
          _buildInfoRow('Type', pet.type.toUpperCase()),
          _buildInfoRow('Breed', pet.breed),
          _buildInfoRow('Color', pet.color),
          if (pet.collarColor.isNotEmpty)
            _buildInfoRow('Collar Color', pet.collarColor),
          if (pet.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              pet.description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerInfoCard(BuildContext context) {
    return _frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('👤 Owner Information'),
          const SizedBox(height: 16),
          _buildInfoRow('Name', pet.ownerName),
          _buildInfoRow('Phone', pet.ownerPhone),
          _buildInfoRow('Email', pet.ownerEmail),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return _frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('📍 Location Information'),
          const SizedBox(height: 16),
          _buildInfoRow('Address', pet.address),
          _buildInfoRow('Last Seen', _dateFormat.format(pet.lastSeenDate)),
          _buildInfoRow('Posted', _dateFormat.format(pet.createdAt)),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _callOwner,
            icon: const Icon(Icons.phone),
            label: const Text('Call Owner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[400],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _messageOwner,
            icon: const Icon(Icons.message, color: Colors.white),
            label: const Text('Send Message'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frostedCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _cardTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Future<void> _callOwner() async {
    final phoneUrl = Uri.parse('tel:${pet.ownerPhone}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }
  }

  Future<void> _messageOwner() async {
    final smsUrl = Uri.parse('sms:${pet.ownerPhone}');
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    }
  }

  Future<void> _sharePetDetails() async {
    // Implement share functionality using share_plus
    // Example: await Share.share('Check out this ${pet.status} pet: ${pet.name}');
  }
}