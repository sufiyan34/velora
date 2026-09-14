import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

/// A small pill badge with a leading dot — used for status and stock state.
class AdminBadge extends StatelessWidget {
  const AdminBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  factory AdminBadge.status(bool isActive) => AdminBadge(
        label: isActive ? 'Active' : 'Inactive',
        foreground: isActive ? AdminColors.success : AdminColors.muted,
        background: isActive ? AdminColors.successTint : const Color(0xFFEFEDF3),
      );

  factory AdminBadge.stock({required int stock}) {
    if (stock <= 0) {
      return const AdminBadge(
        label: 'Out of stock',
        foreground: AdminColors.danger,
        background: AdminColors.dangerTint,
      );
    }
    if (stock <= 5) {
      return AdminBadge(
        label: 'Low · $stock left',
        foreground: AdminColors.warn,
        background: AdminColors.warnTint,
      );
    }
    return AdminBadge(
      label: '$stock in stock',
      foreground: const Color(0xFF3E6B4E),
      background: const Color(0xFFEEF3EF),
    );
  }

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AdminText.body(11.5, weight: FontWeight.w600, color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Colour swatch with initials, standing in for real product/category
/// photography until images are wired up.
class AdminSwatch extends StatelessWidget {
  const AdminSwatch({super.key, required this.seed, this.size = 38});

  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AdminColors.swatchFor(seed),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Text(
        initialsFor(seed),
        style: AdminText.display(size * 0.4, color: Colors.white),
      ),
    );
  }
}
