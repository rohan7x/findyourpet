// lib/widgets/animated_pet_card.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class AnimatedPetCard extends StatefulWidget {
  final String imageUrl; // local asset or network
  final String name;
  final String subtitle;
  final VoidCallback? onTap;
  final double height;

  const AnimatedPetCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.subtitle,
    this.onTap,
    this.height = 180,
  });

  @override
  State<AnimatedPetCard> createState() => _AnimatedPetCardState();
}

class _AnimatedPetCardState extends State<AnimatedPetCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(0, _floatAnim.value),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 24,
                    child: SizedBox(
                      height: widget.height,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: Stack(
                              children: [
                                // background gradient accent
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.teal.withOpacity(0.12), AppColors.purple.withOpacity(0.08)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),
                                // pet image with slight scale & clip
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Hero(
                                      tag: 'pet-${widget.name}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image(
                                          image: widget.imageUrl.startsWith('http')
                                              ? NetworkImage(widget.imageUrl) as ImageProvider
                                              : AssetImage(widget.imageUrl),
                                          height: widget.height - 24,
                                          width: widget.height - 24,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                                  SizedBox(height: 6),
                                  Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.2)),
                                  Spacer(),
                                  Row(
                                    children: [
                                      ThreeActionButton(icon: Icons.location_on, label: "Nearby"),
                                      SizedBox(width: 8),
                                      ThreeActionButton(icon: Icons.favorite_border, label: "Save"),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ThreeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const ThreeActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neonBlue),
          SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
