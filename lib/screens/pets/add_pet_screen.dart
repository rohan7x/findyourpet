// // lib/screens/add_pet_screen.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
// import '../../config.dart'; // adjust the relative path if needed


// class AddPetScreen extends StatefulWidget {
//   const AddPetScreen({Key? key}) : super(key: key);

//   @override
//   State<AddPetScreen> createState() => _AddPetScreenState();
// }

// class _AddPetScreenState extends State<AddPetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _breedController = TextEditingController();
//   final _descController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _reporterNameController = TextEditingController();
//   final _latitudeController = TextEditingController();
//   final _longitudeController = TextEditingController();
//   DateTime? _lastSeenDate;
//   List<XFile> _images = [];

//   bool _isSubmitting = false;
//   String _petType = 'lost'; // 'lost' or 'found'

//   Future<void> _pickImages() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickMultiImage();
//     if (picked.isNotEmpty) {
//       setState(() {
//         _images = picked;
//       });
//     }
//   }

//   void _setType(String type) {
//     setState(() {
//       _petType = type;
//       _phoneController.clear();
//       _reporterNameController.clear();
//       _latitudeController.clear();
//       _longitudeController.clear();
//     });
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_images.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select at least one photo")),
//       );
//       return;
//     }

//     if (_petType == 'lost' && _phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please add an owner contact phone for lost pets")),
//       );
//       return;
//     }

//     if (_petType == 'found' &&
//         (_latitudeController.text.trim().isEmpty || _longitudeController.text.trim().isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please provide location coordinates for found pets")),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
     
//       final uri = Uri.parse('${Config.backendUrl}/pets');
//       final request = http.MultipartRequest('POST', uri);

//       // Common fields
//       request.fields['name'] = _nameController.text.trim();
//       request.fields['type'] = _petType;
//       if (_breedController.text.trim().isNotEmpty) request.fields['breed'] = _breedController.text.trim();
//       if (_descController.text.trim().isNotEmpty) request.fields['description'] = _descController.text.trim();
//       if (_addressController.text.trim().isNotEmpty) request.fields['address'] = _addressController.text.trim();
//       if (_lastSeenDate != null) request.fields['lastSeenDate'] = _lastSeenDate!.toIso8601String();

//       // Lost pet owner
//       if (_petType == 'lost') {
//         request.fields['ownerPhone'] = _phoneController.text.trim();
//         // Backend should assign ownerId from logged-in user
//       }

//       // Found pet reporter + location
//       if (_petType == 'found') {
//         request.fields['reporterName'] = _reporterNameController.text.trim();
//         request.fields['reporterPhone'] = _phoneController.text.trim();

//         final lat = double.tryParse(_latitudeController.text.trim()) ?? 0;
//         final lng = double.tryParse(_longitudeController.text.trim()) ?? 0;
//         request.fields['location[type]'] = 'Point';
//         request.fields['location[coordinates][0]'] = lng.toString(); // longitude
//         request.fields['location[coordinates][1]'] = lat.toString(); // latitude
//       }

//       // Attach images
//       for (final image in _images) {
//         final bytes = await image.readAsBytes();
//         final mimeType = lookupMimeType(image.name) ?? 'application/octet-stream';
//         final mimeParts = mimeType.split('/');
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'files',
//             bytes,
//             filename: image.name,
//             contentType: MediaType(mimeParts[0], mimeParts[1]),
//           ),
//         );
//       }

//       final response = await request.send();
//       final respStr = await response.stream.bytesToString();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Pet added successfully")),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed: $respStr")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLost = _petType == 'lost';
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Pet")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ChoiceChip(
//                     label: const Text('Lost'),
//                     selected: isLost,
//                     onSelected: (_) => _setType('lost'),
//                   ),
//                   const SizedBox(width: 12),
//                   ChoiceChip(
//                     label: const Text('Found'),
//                     selected: !isLost,
//                     onSelected: (_) => _setType('found'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: "Pet Name"),
//                 validator: (v) => v == null || v.isEmpty ? "Required" : null,
//               ),
//               TextFormField(
//                 controller: _breedController,
//                 decoration: const InputDecoration(labelText: "Breed (optional)"),
//               ),
//               TextFormField(
//                 controller: _descController,
//                 decoration: InputDecoration(
//                     labelText: isLost ? "Description (optional)" : "Description / notes"),
//               ),
//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: isLost ? "Owner Phone (required)" : "Reporter Phone (optional)",
//                 ),
//                 validator: (v) {
//                   if (isLost && (v == null || v.trim().isEmpty)) return "Owner phone required for lost pets";
//                   return null;
//                 },
//               ),
//               if (!isLost)
//                 TextFormField(
//                   controller: _reporterNameController,
//                   decoration: const InputDecoration(labelText: "Reporter Name (optional)"),
//                 ),
//               if (!isLost)
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _latitudeController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(labelText: "Latitude"),
//                         validator: (v) {
//                           if (!isLost && (v == null || v.trim().isEmpty)) return "Latitude required";
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _longitudeController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(labelText: "Longitude"),
//                         validator: (v) {
//                           if (!isLost && (v == null || v.trim().isEmpty)) return "Longitude required";
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: "Address (optional)"),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(_lastSeenDate == null
//                         ? (isLost ? "No last seen date selected" : "No found date selected")
//                         : "Date: ${_lastSeenDate!.toLocal()}".split(' ')[0]),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime(2100),
//                       );
//                       if (picked != null) setState(() => _lastSeenDate = picked);
//                     },
//                     child: const Text("Select Date"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: [
//                   ..._images.map((img) {
//                     if (kIsWeb) {
//                       return Image.network(
//                         img.path,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.broken_image, size: 100, color: Colors.red),
//                       );
//                     } else {
//                       return Image.file(
//                         File(img.path),
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.broken_image, size: 100, color: Colors.red),
//                       );
//                     }
//                   }),
//                   IconButton(
//                     icon: const Icon(Icons.add_a_photo),
//                     onPressed: _pickImages,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               _isSubmitting
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _submit,
//                       child: Text(isLost ? "Submit Lost Pet" : "Submit Found Pet"),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../config.dart'; // adjust the relative path if needed

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  DateTime? _lastSeenDate;
  List<XFile> _images = [];

  bool _isSubmitting = false;
  String _petType = 'lost'; // 'lost' or 'found'

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images = picked;
      });
    }
  }

  void _setType(String type) {
    setState(() {
      _petType = type;
      _phoneController.clear();
      _reporterNameController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one photo")),
      );
      return;
    }

    if (_petType == 'lost' && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add an owner contact phone")),
      );
      return;
    }

    if (_petType == 'found' &&
        (_latitudeController.text.trim().isEmpty ||
            _longitudeController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide location coordinates")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('${Config.backendUrl}/pets');
      final request = http.MultipartRequest('POST', uri);

      // Common fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['type'] = _petType;
      if (_breedController.text.trim().isNotEmpty)
        request.fields['breed'] = _breedController.text.trim();
      if (_descController.text.trim().isNotEmpty)
        request.fields['description'] = _descController.text.trim();
      if (_addressController.text.trim().isNotEmpty)
        request.fields['address'] = _addressController.text.trim();
      if (_lastSeenDate != null)
        request.fields['lastSeenDate'] = _lastSeenDate!.toIso8601String();

      // Lost pet
      if (_petType == 'lost') {
        request.fields['ownerPhone'] = _phoneController.text.trim();
      }

      // Found pet
      if (_petType == 'found') {
        request.fields['reporterName'] = _reporterNameController.text.trim();
        request.fields['reporterPhone'] = _phoneController.text.trim();

        final lat = double.tryParse(_latitudeController.text.trim()) ?? 0;
        final lng = double.tryParse(_longitudeController.text.trim()) ?? 0;
        request.fields['location[type]'] = 'Point';
        request.fields['location[coordinates][0]'] = lng.toString();
        request.fields['location[coordinates][1]'] = lat.toString();
      }

      // Attach images
      for (final image in _images) {
        final bytes = await image.readAsBytes();
        final mimeType =
            lookupMimeType(image.name) ?? 'application/octet-stream';
        final mimeParts = mimeType.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            bytes,
            filename: image.name,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pet added successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $respStr")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _petType == 'lost';
    final yellow = const Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Report a Pet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Help reunite pets with their families",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ChoiceChip(
                        label: const Text('Lost Pet'),
                        labelStyle: TextStyle(
                            color: isLost ? Colors.black : Colors.white),
                        selected: isLost,
                        selectedColor: yellow,
                        backgroundColor: Colors.grey[850],
                        onSelected: (_) => _setType('lost'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ChoiceChip(
                        label: const Text('Found Pet'),
                        labelStyle: TextStyle(
                            color: !isLost ? Colors.black : Colors.white),
                        selected: !isLost,
                        selectedColor: yellow,
                        backgroundColor: Colors.grey[850],
                        onSelected: (_) => _setType('found'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField("Pet Name *", _nameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null),
                _buildTextField("Breed (optional)", _breedController),
                _buildTextField(
                    isLost
                        ? "Description (optional)"
                        : "Description / notes (optional)",
                    _descController),
                _buildTextField(
                  isLost
                      ? "Owner Phone (required)"
                      : "Reporter Phone (optional)",
                  _phoneController,
                  type: TextInputType.phone,
                  validator: (v) {
                    if (isLost && (v == null || v.isEmpty)) {
                      return "Required for lost pets";
                    }
                    return null;
                  },
                ),
                if (!isLost)
                  _buildTextField("Reporter Name (optional)",
                      _reporterNameController),
                if (!isLost)
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField("Latitude", _latitudeController,
                              type: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField(
                              "Longitude", _longitudeController,
                              type: TextInputType.number)),
                    ],
                  ),
                _buildTextField("Address (optional)", _addressController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _lastSeenDate == null
                            ? "No date selected"
                            : "Date: ${_lastSeenDate!.toLocal()}".split(' ')[0],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _lastSeenDate = picked);
                        }
                      },
                      icon: Icon(Icons.calendar_today, color: yellow),
                      label: Text("Select Date",
                          style: TextStyle(color: yellow, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._images.map((img) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(img.path,
                                width: 100, height: 100, fit: BoxFit.cover)
                            : Image.file(File(img.path),
                                width: 100, height: 100, fit: BoxFit.cover),
                      );
                    }),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: yellow, width: 1.5),
                        ),
                        child: Icon(Icons.add_a_photo, color: yellow, size: 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 8,
                        ),
                        child: Text(
                          isLost
                              ? "Submit Lost Pet"
                              : "Submit Found Pet",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }
}