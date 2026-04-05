// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pet_track/models/pet.dart';

// class PetCard extends StatelessWidget {
//   final Pet pet;
//   final VoidCallback? onTap;

//   const PetCard({
//     super.key,
//     required this.pet,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   // Pet Image
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.grey[200],
//                     ),
//                     child: pet.photoUrls.isNotEmpty
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.network(
//                               pet.photoUrls.first,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Icon(
//                                   Icons.pets,
//                                   size: 40,
//                                   color: Colors.grey[400],
//                                 );
//                               },
//                             ),
//                           )
//                         : Icon(
//                             Icons.pets,
//                             size: 40,
//                             color: Colors.grey[400],
//                           ),
//                   ),
//                   const SizedBox(width: 16),

//                   // Pet Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               pet.name,
//                               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: pet.type == 'lost'
//                                     ? Colors.red.withOpacity(0.1)
//                                     : Colors.green.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 pet.type.toUpperCase(),
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                       color: pet.type == 'lost' ? Colors.red : Colors.green,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         if (pet.breed != null && pet.breed!.isNotEmpty)
//                           Text(
//                             pet.breed!,
//                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                   color: Colors.grey[600],
//                                 ),
//                           ),
//                         const SizedBox(height: 4),
//                         if (pet.ownerName != null)
//                           Text(
//                             'Owner: ${pet.ownerName}',
//                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: Colors.grey[500],
//                                 ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Description
//               if (pet.description != null && pet.description!.isNotEmpty) ...[
//                 Text(
//                   pet.description!,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 12),
//               ],

//               // Additional Details
//               if (pet.address != null && pet.address!.isNotEmpty) ...[
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.location_on_outlined,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         pet.address!,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//               ],
//               if (pet.lastSeenDate != null)
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.access_time,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Last seen: ${DateFormat('MMM dd, yyyy').format(pet.lastSeenDate!)}',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                     ),
//                   ],
//                 ),

//               // Contact Info
//               if (pet.type == 'found' && pet.ownerPhone != null) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.phone,
//                         size: 16,
//                         color: Colors.blue[700],
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         pet.ownerPhone!,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: Colors.blue[700],
//                               fontWeight: FontWeight.w600,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               // Horizontal Photo List
//               if (pet.photoUrls.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 100,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: pet.photoUrls.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(pet.photoUrls[index]),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/widgets/pet_card.dart
import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Image or Carousel if multiple
          if (pet.photoUrls.isNotEmpty)
            Container(
              height: 200,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: pet.photoUrls.length == 1
                    ? Image.network(
                        pet.photoUrls.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            itemCount: pet.photoUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                pet.photoUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          ),
                          // Dots indicator like Instagram
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                pet.photoUrls.length,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Center(
                child: Icon(Icons.pets, size: 60, color: Colors.white54),
              ),
            ),

          // 📋 Pet details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Breed: ${pet.breed ?? 'Unknown'}",
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Location: ${pet.address ?? 'Unknown'}",
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
