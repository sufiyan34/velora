import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.maxWidth = 340,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AdminColors.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 18, color: AdminColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: AdminText.body(13.5),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
